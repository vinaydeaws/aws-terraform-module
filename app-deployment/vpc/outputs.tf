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
output "private_sg_id" {
  description = "ID of the private server Security Group."
  # Ensure the VPC module output provides this exact name
  value       = module.vpc.private_sg_id 
}

output "public_sg_id" {
  value = module.vpc.public_sg_id
}
