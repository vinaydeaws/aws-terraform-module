# ------------------------------------------------------------------
# SECURITY GROUP for ALB
# ------------------------------------------------------------------
# Allows HTTP traffic from anywhere on the internet
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP inbound traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP access from anywhere"
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

# ------------------------------------------------------------------
# APPLICATION LOAD BALANCER
# ------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets # ALB must sit in public subnets

  enable_deletion_protection = true

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ------------------------------------------------------------------
# TARGET GROUP
# ------------------------------------------------------------------
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = "traffic-port"
  }
  tags = {
    Name = "${var.project_name}-tg"
  }
}

# ------------------------------------------------------------------
# LISTENER
# ------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

