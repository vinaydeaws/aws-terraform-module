output "vpc_id" {
  description = "The ID of the VPC."
  value       = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "alb_dns_name" {
  description = "The public endpoint for the application."
  value       = data.terraform_remote_state.ALB.outputs.alb_dns_name
}

# Output the bastion public IP
output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host."
  # Reference the output exposed by the 'ec2' module
  value       = module.ec2.bastion_public_ip
}

# Output the private IP of the Master server
output "master_private_ip" {
  description = "The private IP address of the Master EC2 instance."
  # Access the first element (Master) of the 'private_ips' list exposed by the module
  value       = element(module.ec2.private_ips, 0)
}

# Output the private IP of Node-1 server
output "node_1_private_ip" {
  description = "The private IP address of Node-1 EC2 instance."
  # Access the second element (Node-1) of the 'private_ips' list
  value       = element(module.ec2.private_ips, 1)
}

# Output the private IP of Node-2 server
output "node_2_private_ip" {
  description = "The private IP address of Node-2 EC2 instance."
  # Access the third element (Node-2) of the 'private_ips' list
  value       = element(module.ec2.private_ips, 2)
}

# Output the key name
output "key_pair_name" {
  description = "The name of the SSH key pair."
  value       = module.ec2.key_pair_name
}
