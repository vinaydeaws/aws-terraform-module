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

# Output the private IPs as a list
output "private_ips" {
  description = "List of private IPs for Master, Node-1, and Node-2."
  value       = aws_instance.private_servers.*.private_ip
}

# Output the bastion public IP
output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host."
  value       = aws_eip.bastion_eip.public_ip
}
