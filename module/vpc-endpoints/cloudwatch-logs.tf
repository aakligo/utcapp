

variable "enable_cloudwatch_logs_endpoint" {
  description = "Enable private CloudWatch Logs endpoint"
  type        = bool
  default     = false
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count = var.enable_cloudwatch_logs_endpoint ? 1 : 0

  vpc_id              = aws_security_group.endpoints.vpc_id
  service_name        = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = tolist(
    aws_vpc_endpoint.ssm["ssm"].subnet_ids
  )

  security_group_ids = [
    aws_security_group.endpoints.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-logs-endpoint"
    Environment = var.environment
    Project     = var.project_name
  }
}
