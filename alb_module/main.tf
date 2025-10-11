# This module creates an Internet-facing ALB and a target group for port 80.

# 1. ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allows HTTP/HTTPS access from the internet to the ALB."
  vpc_id      = var.vpc_id

  # Ingress: HTTP (Port 80) from Internet
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
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
    Name = "${var.project_name}-alb-sg"
  }
}

# 2. Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  # ALB must be in the public subnets
  subnets            = var.public_subnet_ids
  enable_deletion_protection = true

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# 3. Target Group (for private EC2 instances on port 80)
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# 4. Listener (Listens on port 80 and forwards to the Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
}

# 5. Add Ingress Rule to Private SG for ALB Traffic
resource "aws_security_group_rule" "allow_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = var.private_sg_id # The private SG created by the VPC module
  source_security_group_id = aws_security_group.alb_sg.id # The SG created here
  description              = "Allow HTTP from ALB SG"
}

