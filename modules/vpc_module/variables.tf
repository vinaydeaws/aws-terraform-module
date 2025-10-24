variable "project_name" {
  description = "Prefix for all resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of Availability Zones to use."
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

