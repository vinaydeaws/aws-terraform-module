variable "project_name" {
  description = "Name used for tagging resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to launch instances into."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EC2 instances."
  type        = list(string)
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "The key pair name for SSH access."
  type        = string
}

variable "alb_target_group_arn" {
  description = "The ARN of the ALB target group to attach instances to."
  type        = string
}

variable "user_data" {
  description = "Startup script to install web server."
  type        = string
}

