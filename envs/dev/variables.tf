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

variable "enable_rds" {
  description = "Whether to deploy the RDS PostgreSQL database"
  type        = bool
  default     = false
}
variable "enable_s3" {
  description = "Whether to deploy the UTC application S3 bucket"
  type        = bool
  default     = false
}
variable "enable_efs" {
  description = "Whether to deploy the EFS shared filesystem"
  type        = bool
  default     = false
}
variable "desired_capacity" {
  description = "Desired number of application EC2 instances"
  type        = number
  default     = 0
}

variable "enable_ssm_endpoints" {
  description = "Enable Systems Manager interface endpoints"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_logs_endpoint" {
  description = "Enable CloudWatch Logs interface endpoint"
  type        = bool
  default     = false
}

variable "enable_secretsmanager_endpoint" {
  description = "Enable Secrets Manager interface endpoint"
  type        = bool
  default     = false
}

variable "enable_cloudwatch" {
  description = "Enable CloudWatch monitoring resources"
  type        = bool
  default     = false
}

variable "pause_environment" {
  description = "Pause cost-generating DEV resources while preserving the core network"
  type        = bool
  default     = false
}
