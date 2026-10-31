# ==========================================
# STO-001: Storage Module Variables

variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "enable_s3" {
  description = "Enable the S3 bucket"
  type        = bool
  default     = false
}

variable "enable_efs" {
  description = "Enable the EFS shared filesystem"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Globally unique name for the application S3 bucket"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EFS networking"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private application subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Application security group allowed to access EFS"
  type        = string
}