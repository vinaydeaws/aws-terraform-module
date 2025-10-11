	variable "project_name" {
  description = "Name used for tagging resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones to deploy subnets into."
  type        = number
  default     = 2
}

