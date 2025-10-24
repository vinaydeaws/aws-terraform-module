output "vpc_id" {
  description = "The ID of the VPC."
  value       = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "alb_dns_name" {
  description = "The public endpoint for the application."
  value       = data.terraform_remote_state.ALB.outputs.alb_dns_name
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion Host."
  value       = module.ec2.bastion_public_ip
}

output "app_server_private_ips" {
  description = "Private IPs of the application servers."
  value       = module.ec2.private_ip_addresses
}

output "ssh_private_key" {
  description = "The generated private key for SSH login."
  value       = module.ec2.ssh_private_key
  sensitive   = true
}
