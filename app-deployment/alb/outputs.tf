output "target_group_arn" {
  description = "The ARN of the ALB's target group for EC2 instances to attach to."
  value       = module.alb.target_group_arn
}

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

