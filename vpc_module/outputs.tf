output "vpc_id" {
  description = "The ID of the newly created VPC."
  value       = aws_vpc.main.id
}

output "public_ec2_ip" {
  description = "The Elastic IP address assigned to the public jump box EC2."
  # The public IP is provided by the allocated EIP resource.
  value       = aws_eip.public_ec2_eip.public_ip
}

output "key_pair_instructions" {
  description = "Important: Location of the private key file."
  value       = "Your private key is saved to 'login_key.pem'. Use this file with SSH: ssh -i login_key.pem ec2-user@<PUBLIC_IP>"
}

