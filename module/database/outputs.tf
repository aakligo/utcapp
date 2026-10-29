
# ==========================================
# DB-001: RDS PostgreSQL Outputs
# UTC Student Services Portal
# ==========================================

output "db_instance_id" {
  description = "RDS PostgreSQL instance identifier"
  value       = aws_db_instance.this.id
}

output "db_endpoint" {
  description = "RDS PostgreSQL connection endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "RDS PostgreSQL connection port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "PostgreSQL database name"
  value       = aws_db_instance.this.db_name
}

output "db_master_secret_arn" {
  description = "ARN of the AWS-managed database master password secret"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = aws_db_subnet_group.this.name
}
