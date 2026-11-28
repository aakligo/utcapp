locals {
  effective_enable_alb                      = var.pause_environment ? false : var.enable_alb
  effective_enable_rds                      = var.pause_environment ? false : var.enable_rds
  effective_desired_capacity                = var.pause_environment ? 0 : var.desired_capacity
  effective_enable_ssm_endpoints            = var.pause_environment ? false : var.enable_ssm_endpoints
  effective_enable_cloudwatch_logs_endpoint = var.pause_environment ? false : var.enable_cloudwatch_logs_endpoint
  effective_enable_secretsmanager_endpoint  = var.pause_environment ? false : var.enable_secretsmanager_endpoint
}
