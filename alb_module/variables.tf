variable "project_name" {
  description = "Name used for tagging resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the ALB into."
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "target_port" {
  description = "The port for the target group and EC2 instances."
  type        = number
  default     = 80
}

