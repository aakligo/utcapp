# ==========================================
# VPC ENDPOINTS MODULE
# Project: UTC Student Services Portal
# ==========================================

# Security group for interface endpoints
resource "aws_security_group" "endpoints" {
  name_prefix = "${var.project_name}-${var.environment}-vpce-"
  description = "Security group for VPC interface endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpce-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Allow HTTPS from application servers to endpoints
resource "aws_vpc_security_group_ingress_rule" "https_from_app" {
  security_group_id            = aws_security_group.endpoints.id
  referenced_security_group_id = var.app_security_group_id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow HTTPS from application EC2 instances"
}

# Allow outbound traffic from endpoint ENIs
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.endpoints.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  description = "Allow outbound traffic"
}

# AWS Systems Manager interface endpoints
locals {
  ssm_services = toset([
    "ssm",
    "ssmmessages",
    "ec2messages",
  ])
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = local.ssm_services

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-${each.value}-endpoint"
    Environment = var.environment
    Project     = var.project_name
  }
}


# S3 Gateway endpoint for private application subnets
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [var.app_route_table_id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-endpoint"
    Environment = var.environment
    Project     = var.project_name
  }
}
