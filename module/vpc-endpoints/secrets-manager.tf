# Secrets Manager Private VPC Endpoint
# Disabled until deployment approval

variable "enable_secretsmanager_endpoint" {
  description = "Enable Secrets Manager interface VPC endpoint"
  type        = bool
  default     = false
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count = var.enable_secretsmanager_endpoint ? 1 : 0

  vpc_id              = aws_security_group.endpoints.vpc_id
  service_name        = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-secrets-endpoint"
    Environment = var.environment
    Project     = var.project_name
  }
}
