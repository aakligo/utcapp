
# Request an SSL/TLS certificate for HTTPS
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  # Create replacement certificate before
  # removing an existing managed certificate
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = var.domain_name
    Project     = var.project_name
    Environment = var.environment
  }
}
# ==========================================
# ROUTE 53 DNS VALIDATION RECORD
# ==========================================

# Create the DNS record required to validate
# the ACM certificate for utc.triplearides.com
resource "aws_route53_record" "validation" {
  for_each = {
    for option in aws_acm_certificate.this.domain_validation_options :
    option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  zone_id = var.hosted_zone_id

  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  allow_overwrite = false
}

# ==========================================
# WAIT FOR ACM CERTIFICATE VALIDATION
# ==========================================

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [
    for record in aws_route53_record.validation :
    record.fqdn
  ]
}