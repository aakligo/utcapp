# VPC ENDPOINTS MODULE OUTPUTS
# Project: UTC Student Services Portal

output "endpoint_security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = aws_security_group.endpoints.id
}

output "ssm_endpoint_ids" {
  description = "IDs of the Systems Manager VPC endpoints"

  value = {
    for service, endpoint in aws_vpc_endpoint.ssm :
    service => endpoint.id
  }
}

output "ssm_endpoint_dns" {
  description = "DNS entries for Systems Manager endpoints"

  value = {
    for service, endpoint in aws_vpc_endpoint.ssm :
    service => endpoint.dns_entry
  }
}