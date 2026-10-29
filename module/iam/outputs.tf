# ============================================================
# UTC STUDENT SERVICES PORTAL
# MODULE: IAM
# FILE: outputs.tf
#
# PURPOSE:
# Expose IAM resource information to other Terraform
# modules and environment configurations.
# ============================================================


# ------------------------------------------------------------
# 1. EC2 IAM ROLE NAME
#
# Returns the name of the IAM role created by this module.
# Example: utc-app-dev-ec2-role
# ------------------------------------------------------------

output "ec2_role_name" {
  description = "Name of the IAM role assigned to EC2"
  value       = aws_iam_role.ec2_role.name
}


# ------------------------------------------------------------
# 2. EC2 IAM ROLE ARN
#
# Returns the Amazon Resource Name of the EC2 IAM role.
# This can be used by other AWS resources and IAM policies.
# ------------------------------------------------------------

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}


# ------------------------------------------------------------
# 3. EC2 INSTANCE PROFILE NAME
#
# The EC2 Launch Template will use this output to
# associate the IAM role with application servers.
# ------------------------------------------------------------

output "ec2_instance_profile_name" {
  description = "Name of the EC2 IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}


# ------------------------------------------------------------
# 4. EC2 INSTANCE PROFILE ARN
#
# Returns the ARN of the EC2 instance profile.
# ------------------------------------------------------------

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}
