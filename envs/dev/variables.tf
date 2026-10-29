variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones"
  type        = number
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}
variable "enable_alb" {
  description = "Enable or disable the Application Load Balancer"
  type        = bool
  default     = false
}


# ==========================================
# DB-001: RDS Deployment Control
# ==========================================

variable "enable_rds" {
  description = "Whether to deploy the RDS PostgreSQL database"
  type        = bool
  default     = false
}
