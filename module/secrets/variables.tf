# SEC-002: Secrets Management Variables
variable "project_name" {
  description = "UTC project name"
  type        = string
}
variable "environment" {
  description = "Deployment environment"
  type        = string
}
variable "ec2_role_name" {
  description = "Existing EC2 IAM role name"
  type        = string
}
variable "approved_secret_arns" {
  description = "Secret ARNs the application is approved to read"
  type        = list(string)
  default     = []
}