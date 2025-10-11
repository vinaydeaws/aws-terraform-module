# These outputs are critical for the other modules to consume.

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "A list of public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "A list of private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

