# This module creates a Key Pair, a Public Bastion Host, and Private App Servers.

# 1. SSH Key Pair Generation
resource "tls_private_key" "login_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "login" {
  key_name   = "${var.project_name}-login-key"
  public_key = tls_private_key.login_key.public_key_openssh
}

# 2. Public Bastion Host EC2 (For SSH access)
# Creates a single instance in the first public subnet.
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.bastion_instance_type
  subnet_id     = element(var.public_subnet_ids, 0) # Place in first public subnet
  key_name      = aws_key_pair.login.key_name
  associate_public_ip_address = true # Needed for EIP below
  vpc_security_group_ids = [var.public_sg_id]

  tags = {
    Name = "${var.project_name}-bastion-host"
  }
}

# 3. EIP for Public Bastion Host (Reallocateable)
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  domain      = "vpc"
  tags = {
    Name = "${var.project_name}-bastion-eip"
  }
}

# 4. Private App Servers EC2 (2 instances, one in each private subnet)
resource "aws_instance" "app_servers" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.app_instance_type
  subnet_id     = element(var.private_subnet_ids, count.index)
  key_name      = aws_key_pair.login.key_name
  # Explicitly do NOT associate a public IP
  associate_public_ip_address = false
  vpc_security_group_ids = [var.private_sg_id]

  # Attach to the ALB Target Group
  # Note: This requires the ALB target group to be ready before EC2 is created
  # and this module depends on the ALB module deployment being complete.
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World from App Server ${count.index + 1}" > index.html
              sudo nohup python3 -m http.server 80 &
              EOF

  tags = {
    Name = "${var.project_name}-app-server-${count.index + 1}"
  }
}

# Attach private instances to the Target Group
resource "aws_lb_target_group_attachment" "app_servers" {
  count            = 2
  target_group_arn = var.target_group_arn
  target_id        = element(aws_instance.app_servers.*.id, count.index)
  port             = 80
}

# Data source for Amazon Linux 2 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
 filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

