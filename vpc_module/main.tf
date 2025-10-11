# ------------------------------------------------------------------
# VPC: The main network
# ------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ------------------------------------------------------------------
# INTERNET GATEWAY & NAT GATEWAY
# ------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags = {
    Name = "${var.project_name}-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}

# ------------------------------------------------------------------
# SUBNETS (PUBLIC & PRIVATE)
# ------------------------------------------------------------------
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true # Public subnets need this for EC2 if launched here
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name    = "${var.project_name}-public-subnet-${count.index}"
    Tier    = "Public"
  }
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.az_count) # Offset CIDR block
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name    = "${var.project_name}-private-subnet-${count.index}"
    Tier    = "Private"
  }
}

# ------------------------------------------------------------------
# ROUTE TABLES
# ------------------------------------------------------------------

# Public Route Table (0.0.0.0/0 -> IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project_name}-public-rtb"
  }
}

# Private Route Table (0.0.0.0/0 -> NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.project_name}-private-rtb"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
