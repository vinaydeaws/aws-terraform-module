output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = aws_subnet.private.*.id
}

output "private_sg_id" {
  description = "ID of the private server Security Group."
  value       = aws_security_group.private_sg.id
}

output "public_sg_id" {
  description = "ID of the public bastion Security Group."
  value       = aws_security_group.public_sg.id
}

