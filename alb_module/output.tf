output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group to register instances with."
  value       = aws_lb_target_group.main.arn
}

output "alb_sg_id" {
  description = "The Security Group ID of the ALB."
  value       = aws_security_group.alb.id
}

