# ==========================================
# ACM MODULE VARIABLES
# Project: UTC Student Services Portal
# ==========================================

# Domain name for the SSL/TLS certificate
variable "domain_name" {
  description = "Domain name for the ACM certificate"
  type        = string
}

# Project name for resource tagging
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Deployment environment
variable "environment" {
  description = "Environment such as dev or prod"
  type        = string

} # Existing public Route 53 hosted zone
variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID"
  type        = string
}