# ==========================================
# ACM MODULE OUTPUTS
# Project: UTC Student Services Portal
# ==========================================

# Export the ACM certificate ARN
# The ALB HTTPS listener will use this ARN
output "certificate_arn" {
  description = "ARN of the ACM SSL/TLS certificate"
  value       = aws_acm_certificate.this.arn
}

# Export the certificate domain name
output "certificate_domain_name" {
  description = "Domain name associated with the ACM certificate"
  value       = aws_acm_certificate.this.domain_name
}

# Export DNS validation information
# Used later to create Route 53 validation records
output "domain_validation_options" {
  description = "DNS validation records required by ACM"
  value       = aws_acm_certificate.this.domain_validation_options
}