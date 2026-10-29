# Project name used to identify AWS resources
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Environment where resources will be deployed
# Example: dev, stage, or prod
variable "environment" {
  description = "Deployment environment"
  type        = string
}

# Existing VPC ID from our network module
# We will reuse the VPC instead of creating another one
variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

# Port used by the application servers
# Only the ALB will be allowed to access this port
variable "app_port" {
  description = "Port used by the application"
  type        = number
  default     = 3000
}

# PostgreSQL database port
# Only application servers will be allowed to connect
variable "db_port" {
  description = "Port used by the RDS database"
  type        = number
  default     = 5432
}