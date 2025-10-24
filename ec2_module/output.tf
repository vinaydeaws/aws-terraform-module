# Output the name of the generated key pair
output "key_pair_name" {
  description = "The name of the SSH key pair."
  value       = aws_key_pair.login.key_name
}

# Output the local path where the private key (.pem) file was saved
output "key_file_path" {
  description = "The local path where the private key was saved (chmod 400 is recommended)."
  value       = local_file.key_pem.filename
}

# Output the public IP of the Bastion Host
output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host."
  value       = aws_eip.bastion_eip.public_ip
}

# Output the private IP of the Master server
output "master_private_ip" {
  description = "The private IP address of the Master EC2 instance (index 0)."
  value       = aws_instance.private_servers[0].private_ip
}

# Output the private IP of Node-1 server
output "node_1_private_ip" {
  description = "The private IP address of Node-1 EC2 instance (index 1)."
  value       = aws_instance.private_servers[1].private_ip
}

# Output the private IP of Node-2 server
output "node_2_private_ip" {
  description = "The private IP address of Node-2 EC2 instance (index 2)."
  value       = aws_instance.private_servers[2].private_ip
}
