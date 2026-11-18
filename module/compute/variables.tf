
variable "project_name" {
  description = "Name of the UTC project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 application servers"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}


variable "private_subnet_ids" {
  description = "Private application subnet IDs"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID for EC2 servers"
  type        = string
}


variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}


variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 0
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 0
}


variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 3
}

variable "target_group_arns" {
  description = "Optional ALB target group ARNs"
  type        = list(string)
  default     = []
}
# DB-001: AWS Secrets Manager integration
variable "db_secret_arn" {
  description = "ARN of the RDS-managed PostgreSQL secret"
  type        = string
  default     = ""
}
# DB-001: PostgreSQL database hostname
variable "db_host" {
  description = "Private RDS PostgreSQL hostname"
  type        = string
  default     = ""
}