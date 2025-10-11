output "instance_ids" {
  description = "IDs of the created EC2 instances."
  value       = aws_instance.web.*.id
}

output "instance_private_ips" {
  description = "Private IP addresses of the created EC2 instances."
  value       = aws_instance.web.*.private_ip
}

