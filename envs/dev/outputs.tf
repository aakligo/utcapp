output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "app_subnet_ids" {
  value = module.network.app_subnet_ids
}

output "database_subnet_ids" {
  value = module.network.database_subnet_ids
}

output "availability_zones" {
  value = module.network.availability_zones
}

# IAC-001: Application Load Balancer Outputs

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = try(module.alb[0].alb_dns_name, null)
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = try(module.alb[0].alb_arn, null)
}

output "alb_target_group_arn" {
  description = "ARN of the ALB application target group"
  value       = try(module.alb[0].target_group_arn, null)
}

# ==========================================
# IAC-001: ACM Certificate Outputs
# ==========================================

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate used for HTTPS"
  value       = module.acm.certificate_arn
}

output "acm_certificate_domain_name" {
  description = "Domain name associated with the ACM certificate"
  value       = module.acm.certificate_domain_name
}


# ==========================================
# IAC-001: Compute Outputs
# ==========================================

output "launch_template_id" {
  description = "ID of the EC2 Launch Template"
  value       = module.compute.launch_template_id
}

output "autoscaling_group_name" {
  description = "Name of the EC2 Auto Scaling Group"
  value       = module.compute.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the EC2 Auto Scaling Group"
  value       = module.compute.autoscaling_group_arn
}

# ==========================================
# IAC-001: IAM Outputs
# ==========================================

output "ec2_role_name" {
  description = "Name of the EC2 IAM role"
  value       = module.iam.ec2_role_name
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = module.iam.ec2_role_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.iam.ec2_instance_profile_name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = module.iam.ec2_instance_profile_arn
}

# ==========================================
# IAC-001: RDS PostgreSQL Outputs
# ==========================================

output "db_instance_id" {
  description = "RDS PostgreSQL instance identifier"
  value       = try(module.database[0].db_instance_id, null)
}

output "db_endpoint" {
  description = "RDS PostgreSQL connection endpoint"
  value       = try(module.database[0].db_endpoint, null)
}

output "db_port" {
  description = "RDS PostgreSQL connection port"
  value       = try(module.database[0].db_port, null)
}

output "db_name" {
  description = "PostgreSQL database name"
  value       = try(module.database[0].db_name, null)
}

output "db_subnet_group_name" {
  description = "RDS database subnet group name"
  value       = try(module.database[0].db_subnet_group_name, null)
}

output "db_master_secret_arn" {
  description = "ARN of the AWS-managed RDS master password secret"
  value       = try(module.database[0].db_master_secret_arn, null)
}

# ==========================================
# IAC-001: S3 and EFS Storage Outputs
# ==========================================

output "s3_bucket_id" {
  description = "ID of the UTC student documents S3 bucket"
  value       = module.storage.s3_bucket_id
}

output "efs_file_system_id" {
  description = "ID of the EFS filesystem"
  value       = module.storage.efs_file_system_id
}

output "efs_file_system_arn" {
  description = "ARN of the EFS filesystem"
  value       = module.storage.efs_file_system_arn
}

output "efs_security_group_id" {
  description = "Security group ID assigned to EFS"
  value       = module.storage.efs_security_group_id
}

output "efs_mount_target_ids" {
  description = "IDs of EFS mount targets"
  value       = module.storage.efs_mount_target_ids
}

# ==========================================
# IAC-001: CloudWatch and SNS Outputs
# ==========================================

output "cloudwatch_log_group_name" {
  description = "Name of the application CloudWatch log group"
  value       = module.monitoring.log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the application CloudWatch log group"
  value       = module.monitoring.log_group_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS monitoring alerts topic"
  value       = module.monitoring.sns_topic_arn
}

output "high_cpu_alarm_name" {
  description = "Name of the EC2 high CPU CloudWatch alarm"
  value       = module.monitoring.high_cpu_alarm_name
}
