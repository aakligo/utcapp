# ==========================================
# SECURITY GROUP MODULE OUTPUTS
# Project: UTC Student Services Portal
# ==========================================

# Export existing ALB security group ID
output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

# Export existing application security group ID
output "app_security_group_id" {
  description = "Security group ID for EC2 application servers"
  value       = aws_security_group.app.id
}

# Export existing RDS security group ID
output "rds_security_group_id" {
  description = "Security group ID for the RDS database"
  value       = aws_security_group.rds.id
}