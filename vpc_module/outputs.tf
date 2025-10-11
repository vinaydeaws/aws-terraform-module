output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "List of Public Subnet IDs for load balancers."
  value       = aws_subnet.public.*.id
}

output "private_subnets" {
  description = "List of Private Subnet IDs for EC2 instances."
  value       = aws_subnet.private.*.id
}

