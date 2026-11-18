# ==========================================
# SECURITY GROUPS MODULE
# Project: UTC App
# ==========================================

# Common naming convention
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ==========================================
# 1. ALB SECURITY GROUP
# ==========================================

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name_prefix}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Allow HTTP traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow HTTP from internet"
}

# Allow HTTPS traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow HTTPS from internet"
}

# Allow ALB to send traffic to application servers
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"

  description = "Allow traffic from ALB to application"
}
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Security group for application servers"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name_prefix}-app-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Only the ALB can access the application port
resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"

  description = "Allow application traffic from ALB only"
}
resource "aws_vpc_security_group_egress_rule" "app_to_rds" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"

  description = "Allow PostgreSQL traffic to RDS"
}



# ==========================================
# 3. RDS SECURITY GROUP
# ==========================================

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name_prefix}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Only application servers can connect to RDS
resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id = aws_security_group.rds.id

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"

  description = "Allow PostgreSQL from application only"
}
# OBS-001: Allow private application servers to access S3
# through the S3 Gateway VPC Endpoint
resource "aws_vpc_security_group_egress_rule" "app_to_s3" {
  security_group_id = aws_security_group.app.id

  prefix_list_id = "pl-63a5400a"
  from_port      = 443
  to_port        = 443
  ip_protocol    = "tcp"

  description = "Allow HTTPS to Amazon S3 via Gateway endpoint"
}
