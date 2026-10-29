# ============================================================
# UTC STUDENT SERVICES PORTAL
# MODULE: IAM
# FILE: variables.tf
#
# PURPOSE:
# Define reusable input variables for the IAM module.
# These inputs allow the same IAM module to be used
# across Dev, Stage, and Prod environments.
# ============================================================


# Project name used when naming AWS resources.
# Example: utc-app
variable "project_name" {
  description = "Name of the UTC application project"
  type        = string
}


# Deployment environment.
# Examples: dev, stage, prod
variable "environment" {
  description = "Deployment environment"
  type        = string
}


# AWS-managed policy for Systems Manager.
# Allows EC2 instances to communicate with SSM.
variable "ssm_policy_arn" {
  description = "AWS-managed SSM policy ARN"
  type        = string

  default = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# AWS-managed policy for CloudWatch Agent.
# Allows EC2 instances to publish logs and metrics.
variable "cloudwatch_policy_arn" {
  description = "AWS-managed CloudWatch Agent policy ARN"
  type        = string

  default = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}