# ==========================================
# STO-001: S3 Storage Outputs
# ==========================================

output "s3_bucket_name" {
  description = "Name of the UTC application S3 bucket"
  value       = try(aws_s3_bucket.this[0].bucket, null)
}

output "s3_bucket_arn" {
  description = "ARN of the UTC application S3 bucket"
  value       = try(aws_s3_bucket.this[0].arn, null)
}

output "s3_bucket_id" {
  description = "ID of the UTC application S3 bucket"
  value       = try(aws_s3_bucket.this[0].id, null)
}
# ==========================================
# STO-001: Amazon EFS Outputs
# ==========================================

output "efs_file_system_id" {
  description = "ID of the EFS filesystem"
  value       = try(aws_efs_file_system.this[0].id, null)
}

output "efs_file_system_arn" {
  description = "ARN of the EFS filesystem"
  value       = try(aws_efs_file_system.this[0].arn, null)
}

output "efs_security_group_id" {
  description = "Security group ID assigned to EFS"
  value       = try(aws_security_group.efs[0].id, null)
}

output "efs_mount_target_ids" {
  description = "IDs of the EFS mount targets"
  value       = aws_efs_mount_target.this[*].id
}