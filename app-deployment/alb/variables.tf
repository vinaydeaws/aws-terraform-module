variable "aws_region" {
  description = "The AWS region where the network resources exist."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "A unique prefix for the ALB resources."
  type        = string
  default     = "prod-webapp"
}
