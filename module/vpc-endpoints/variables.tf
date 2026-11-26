# ==========================================
# VPC ENDPOINTS MODULE VARIABLES
# Project: UTC Student Services Portal
# ==========================================

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the endpoints"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private application subnet IDs"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Existing EC2 application security group ID"
  type        = string
}
variable "app_route_table_id" {
  description = "Existing private application route table ID for the S3 Gateway endpoint"
  type        = string
}

variable "enable_ssm_endpoints" {
  description = "Enable Systems Manager interface VPC endpoints"
  type        = bool
  default     = false
}
