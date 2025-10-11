# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Required for key generation
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# 1. VPC and Networking Resources
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "ProdVPC"
    Environment = "Production"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "ProdVPC-IGW" }
}

# Fetch available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------------
# 2. Subnets (2 Public, 2 Private)
# -----------------------------------------------------------------------------

# Public Subnets (AZ A and B)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Allows EC2 in this subnet to get a Public IP by default

  tags = {
    Name = "Public-Subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Private Subnets (AZ A and B)
resource "aws_subnet" "private" {
  count                   = length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-Subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# -----------------------------------------------------------------------------
# 3. NAT Gateway and Routing
# -----------------------------------------------------------------------------

# EIP for NAT Gateway (Must be in a public subnet)
resource "aws_eip" "nat" {
  domain        = vpc
  depends_on = [aws_internet_gateway.igw]
  tags       = { Name = "NAT-Gateway-EIP" }
}

# NAT Gateway (placed in the first public subnet: public[0])
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "ProdVPC-NAT-GW" }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Public-Route-Table" }
}

# Public Route: Traffic to 0.0.0.0/0 goes to the Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Private-Route-Table" }
}

# Private Route: Traffic to 0.0.0.0/0 goes to the NAT Gateway
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# -----------------------------------------------------------------------------
# 4. Key Pair Generation
# -----------------------------------------------------------------------------

# Generate a new private key locally
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a Key Pair in AWS using the public key
resource "aws_key_pair" "login_key" {
  key_name   = "login_key"
  public_key = tls_private_key.key.public_key_openssh
}

# Save the private key to a file using local-exec
resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "login_key.pem"
  # This command ensures the key file has the correct secure permissions
  provisioner "local-exec" {
    command = "chmod 400 ${local_file.private_key.filename}"
  }
}

# -----------------------------------------------------------------------------
# 5. Security Groups (Jump Box Pattern)
# -----------------------------------------------------------------------------

# SG for Public Jump Box (sg1) - Allows SSH from the internet
resource "aws_security_group" "public_sg1" {
  vpc_id      = aws_vpc.main.id
  name        = "public-sg1"
  description = "Allow inbound SSH access from the internet (Jump Box)"

  # Ingress: SSH from your IP (or 0.0.0.0/0 for demo, but restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: Change to your trusted IP range for production
    description = "SSH from anywhere (Restrict in prod!)"
  }

  # Egress: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "public-sg1" }
}

# SG for Private Backend (sg2) - Allows SSH ONLY from sg1
resource "aws_security_group" "private_sg2" {
  vpc_id      = aws_vpc.main.id
  name        = "private-sg2"
  description = "Allow inbound SSH only from the Public Jump Box (sg1)"

  # Ingress: SSH from public_sg1 only (Production-secure access)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg1.id]
    description     = "Allow SSH from Public Jump Box (sg1)"
  }

  # Egress: Allow all outbound traffic (via NAT Gateway)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "private-sg2" }
}

# -----------------------------------------------------------------------------
# 6. EC2 Instances
# -----------------------------------------------------------------------------

# Public EC2 Instance (The Jump Box)
resource "aws_instance" "public_ec2" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public[0].id
  key_name      = aws_key_pair.login_key.key_name

  vpc_security_group_ids = [
    aws_security_group.public_sg1.id
  ]

  # Disable default public IP assignment since we are attaching an EIP
  # associate_public_ip_address = false 
  
  tags = {
    Name = "Public-EC2-JumpBox"
  }
}

# EIP for Public EC2 (Reallocateable)
resource "aws_eip" "public_ec2_eip" {
  domain        = vpc
  instance   = aws_instance.public_ec2.id
  depends_on = [aws_internet_gateway.igw]
  tags       = { Name = "Public-EC2-EIP" }
}

# Private EC2 Instance (Backend Server)
resource "aws_instance" "private_ec2" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private[0].id
  key_name      = aws_key_pair.login_key.key_name

  vpc_security_group_ids = [
    aws_security_group.private_sg2.id
  ]

  # MUST NOT associate a public IP for private security
  associate_public_ip_address = false 

  tags = {
    Name = "Private-EC2-Backend"
  }
}

