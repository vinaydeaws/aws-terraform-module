output "target_group_arn" {
  description = "The ARN of the target group for EC2 instances to attach to."
  value       = aws_lb_target_group.main.arn
}

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_sg_id" {
  description = "The ID of the ALB Security Group."
  value       = aws_security_group.alb_sg.id
}

