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

# 1.1 Download Private Key to Local System
resource "local_file" "key_pem" {
  # Use the project name in the key file name for clarity
  content  = tls_private_key.login_key.private_key_pem
  # Downloads to the requested path: /home/vinay/terraform/projectname-login-key.pem
  filename = "/home/vinay/terraform/${aws_key_pair.login.key_name}.pem" 
  # Set permissions to read-only for the owner (like 'chmod 400')
  file_permission = "0400"
}

# 2. Public Bastion Host EC2 (t3.micro)
resource "aws_instance" "bastion" {
  ami           = var.ami_id # ami-0a716d3f3b16d290c (Ubuntu)
  instance_type = var.bastion_instance_type # t3.micro
  subnet_id     = element(var.public_subnet_ids, 0) # Place in first public subnet
  key_name      = aws_key_pair.login.key_name
  associate_public_ip_address = true 
  vpc_security_group_ids = [var.public_sg_id]

  tags = {
    Name = "${var.project_name}-bastion-host"
  }
}

# 3. EIP for Public Bastion Host (Reallocateable)
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  domain   = "vpc"
  tags = {
    Name = "${var.project_name}-bastion-eip"
  }
}

# 4. Private EC2 Instances (Master, Node-1, Node-2)
locals {
  private_instance_names = ["master", "node-1", "node-2"]
}

resource "aws_instance" "private_servers" {
  count         = length(local.private_instance_names) # Creates 3 instances
  ami           = var.ami_id # ami-0a716d3f3b16d290c (Ubuntu)
  instance_type = var.private_instance_type # c7i-flex.large
  # Cycle through available private subnets, assuming at least 3
  subnet_id     = element(var.private_subnet_ids, count.index) 
  key_name      = aws_key_pair.login.key_name
  associate_public_ip_address = false
  vpc_security_group_ids = [var.private_sg_id]

  # Re-including original user_data script, adapted for new instance count
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World from ${local.private_instance_names[count.index]}" > index.html
              sudo nohup python3 -m http.server 80 &
              EOF

  tags = {
    Name = "${var.project_name}-${local.private_instance_names[count.index]}"
  }
}

# Attach private instances to the Target Group (Re-added)
resource "aws_lb_target_group_attachment" "private_servers" {
  count            = length(aws_instance.private_servers)
  target_group_arn = var.target_group_arn
  target_id        = element(aws_instance.private_servers.*.id, count.index)
  port             = 80
}
