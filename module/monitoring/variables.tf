# OBS-001: Monitoring Module Variables
variable "project_name" {
  description = "UTC project name"
  type        = string
}
variable "environment" {
  description = "Deployment environment"
  type        = string
}
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring resources"
  type        = bool
  default     = false
}
variable "notification_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}
variable "log_retention_days" {
  description = "CloudWatch Logs retention period"
  type        = number
  default     = 7
}
variable "cpu_threshold" {
  description = "CPU utilization percentage that triggers an alarm"
  type        = number
  default     = 80
}
variable "autoscaling_group_name" {
  description = "Existing EC2 Auto Scaling Group name to monitor"
  type        = string
  default     = ""
}
variable "enable_cloudwatch" {
  description = "Enable CloudWatch log group and CPU alarm"
  type        = bool
  default     = true
}
