	# ------------------------------------------------------------------
# AMI DATA SOURCE
# ------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------
# SECURITY GROUP for EC2
# ------------------------------------------------------------------
# Allows HTTP from ALB (internal communication) and SSH from anywhere (for management)
resource "aws_security_group" "instance" {
  name        = "${var.project_name}-instance-sg"
  description = "Allow HTTP from ALB and SSH from internet"
  vpc_id      = var.vpc_id

  # Allow HTTP access from ALB's Security Group (best practice)
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"] # For simplicity, allowing all. In production, restrict to ALB SG.
  }

  # Allow SSH for management
  ingress {
    description = "SSH access"
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
    Name = "${var.project_name}-instance-sg"
  }
}

# ------------------------------------------------------------------
# EC2 INSTANCE (Deployed in private subnet)
# ------------------------------------------------------------------
resource "aws_instance" "web" {
  count                  = 1 # Start with one instance
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnets[count.index] # Use a private subnet
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = var.user_data # Shell script for installation

  tags = {
    Name = "${var.project_name}-Web-Instance-${count.index}"
  }
}

# ------------------------------------------------------------------
# ATTACH INSTANCE TO TARGET GROUP
# ------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "web" {
  count            = length(aws_instance.web)
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

