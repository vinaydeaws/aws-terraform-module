# This module creates a VPC with 2 public and 2 private subnets, IGW, and NAT Gateway.

# 1. VPC Creation
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 2. Internet Gateway (IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. EIP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# 4. NAT Gateway (Placed in the first public subnet)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.project_name}-nat"
  }
}

# 5. Subnet Creation (Public and Private)
# We use two availability zones (a and b) for high availability.
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index) # 10.10.0.0/24, 10.10.1.0/24
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2) # 10.10.2.0/24, 10.10.3.0/24
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

# 6. Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route for Public RT to IGW
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnets with Public RT
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# 7. Private Route Table
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

# Route for Private RT to NAT Gateway
resource "aws_route" "private_nat_access" {
  count                  = length(aws_route_table.private)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id # All private subnets route to the single NAT GW
}

# Associate Private Subnets with Private RT
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index) # Use one private RT per private subnet (best practice)
}

# 8. Security Groups

# Security Group for Public Bastion Host
resource "aws_security_group" "public_sg" {
  name        = "${var.project_name}-public-sg"
  description = "Allows SSH access from the internet to bastion host."
  vpc_id      = aws_vpc.main.id

  # Ingress: SSH from the Internet
  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-public-sg"
  }
}

# Security Group for Private Application Servers (and SSH access from Public SG)
resource "aws_security_group" "private_sg" {
  name        = "${var.project_name}-private-sg"
  description = "Allows HTTP/SSH access from ALB/Bastion."
  vpc_id      = aws_vpc.main.id

  # Ingress: SSH from Public SG ONLY
  ingress {
    description     = "SSH from Public Bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allows outbound access (via NAT GW)
  }
  tags = {
    Name = "${var.project_name}-private-sg"
  }
}
