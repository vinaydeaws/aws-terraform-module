variable "aws_region" {
  description = "The AWS region where the base resources exist."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "A unique prefix for the EC2 resources."
  type        = string
  default     = "prod-webapp"
}


