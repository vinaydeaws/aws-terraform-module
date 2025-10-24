variable "project_name" {
  description = "Prefix for all resources."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances (Ubuntu: ami-0a716d3f3b16d290c)."
  type        = string
  default     = "ami-0a716d3f3b16d290c"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the bastion host."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for app servers (master, nodes)."
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

variable "private_instance_type" {
  description = "EC2 instance type for the master and node servers."
  type        = string
  default     = "c7i-flex.large"
}
