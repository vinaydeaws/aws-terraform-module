variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "A unique prefix for all network resources."
  type        = string
  default     = "prod-webapp"
}

