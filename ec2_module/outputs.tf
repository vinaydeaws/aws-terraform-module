output "bastion_public_ip" {
  description = "The EIP of the Bastion Host for SSH access."
  value       = aws_eip.bastion_eip.public_ip
}

output "private_ip_addresses" {
  description = "The private IP addresses of the two application servers."
  value       = aws_instance.app_servers.*.private_ip
}

output "ssh_private_key" {
  description = "The generated private key for SSH login (SAVE THIS SECURELY)."
  value       = tls_private_key.login_key.private_key_pem
  sensitive   = true # Mark as sensitive so it's not shown in plan/apply
}

