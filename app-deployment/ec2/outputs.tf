# VPC ID is pulled from the remote state of the network module
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "production-terraform-state-bucket-unique-name-123"
    key    = "app/network.tfstate"
    region = var.aws_region
  }
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = data.terraform_remote_state.network.outputs.vpc_id
}

output "alb_dns_name" {
  description = "The public endpoint for the application."
  value       = data.terraform_remote_state.loadbalancer.outputs.alb_dns_name
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion Host."
  value       = module.compute.bastion_public_ip
}

output "app_server_private_ips" {
  description = "Private IPs of the application servers."
  value       = module.compute.private_ip_addresses
}

output "ssh_private_key" {
  description = "The generated private key for SSH login."
  value       = module.compute.ssh_private_key
  sensitive   = true
}
