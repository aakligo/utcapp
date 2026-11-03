# OBS-001: Monitoring Module Outputs
output "log_group_name" {
  description = "CloudWatch application log group name"
  value       = try(aws_cloudwatch_log_group.application[0].name, null)
}
output "log_group_arn" {
  description = "CloudWatch application log group ARN"
  value       = try(aws_cloudwatch_log_group.application[0].arn, null)
}
output "sns_topic_arn" {
  description = "SNS topic ARN for monitoring alerts"
  value       = try(aws_sns_topic.alerts[0].arn, null)
}
output "high_cpu_alarm_name" {
  description = "CloudWatch high CPU alarm name"
  value       = try(aws_cloudwatch_metric_alarm.high_cpu[0].alarm_name, null)
}
