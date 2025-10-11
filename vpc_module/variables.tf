variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (ubuntu t3.micro)."
  type        = string
  # This AMI ID (ami-0a716d3f3b16d290c) is for ubuntu in eu-north-1, verify if using a different region.
  default     = "ami-0a716d3f3b16d290c"
}

