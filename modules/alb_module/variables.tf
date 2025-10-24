variable "project_name" {
  description = "Prefix for all resources."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID from the network module."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where the ALB will reside."
  type        = list(string)
}

variable "private_sg_id" {
  description = "The ID of the private EC2 security group to allow ingress from the ALB."
  type        = string
}

