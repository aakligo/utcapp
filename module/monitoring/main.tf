
# OBS-001: CloudWatch Logs and SNS
# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "application" {
  count = var.enable_monitoring ? 1 : 0

  name              = "/${var.project_name}/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
# SNS Topic for monitoring alerts
resource "aws_sns_topic" "alerts" {
  count = var.enable_monitoring ? 1 : 0

  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Optional email notification subscription
resource "aws_sns_topic_subscription" "email" {
  count = var.enable_monitoring && trimspace(var.notification_email) != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = trimspace(var.notification_email)
}
# OBS-001: EC2 High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_monitoring && trimspace(var.autoscaling_group_name) != "" ? 1 : 0

  alarm_name        = "${var.project_name}-${var.environment}-high-cpu"
  alarm_description = "Alert when average EC2 CPU utilization exceeds the threshold"

  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts[0].arn
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
