# ==========================================
# ALB MODULE VARIABLES
# Project: UTC App
# ==========================================

# Project name for resource naming
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Deployment environment
variable "environment" {
  description = "Environment such as dev or prod"
  type        = string
}

# Existing VPC created by network module
variable "vpc_id" {
  description = "VPC ID where the ALB will be created"
  type        = string
}

# Existing public subnets from network module
variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

# Existing ALB security group
variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

# Application listening port
variable "app_port" {
  description = "Port used by application servers"
  type        = number
  default     = 3000
}
# ACM certificate ARN for HTTPS
variable "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  type        = string
}