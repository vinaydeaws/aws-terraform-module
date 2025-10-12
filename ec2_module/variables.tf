variable "project_name" {
  description = "Prefix for all resources."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the bastion host."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for app servers."
  type        = list(string)
}

variable "public_sg_id" {
  description = "ID of the public security group for bastion."
  type        = string
}

variable "private_sg_id" {
  description = "ID of the private security group for app servers."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB Target Group to register app servers."
  type        = string
}

variable "bastion_instance_type" {
  description = "EC2 instance type for the bastion host."
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "EC2 instance type for the application servers."
  type        = string
  default     = "t3.micro"
}

