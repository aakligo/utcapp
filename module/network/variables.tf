// Create module/network/variables.tf
// This file declares the input values our network module needs

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name such as dev or prod"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones"
  type        = number
  default     = 3

  validation {
    condition     = contains([2, 3], var.az_count)
    error_message = "Choose either 2 or 3 Availability Zones."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = false
}