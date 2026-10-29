# ============================================================
# UTC STUDENT SERVICES PORTAL
# MODULE: IAM
# FILE: main.tf
#
# PURPOSE:
# Create an IAM role and instance profile for EC2 servers.
#
# This module allows EC2 instances to:
# 1. Connect to AWS Systems Manager.
# 2. Publish logs and metrics using CloudWatch Agent.
#
# The module is reusable across Dev, Stage, and Prod.
# ============================================================


# ------------------------------------------------------------
# 1. IAM TRUST POLICY
#
# Defines which AWS service is allowed to assume the role.
# Here, only the EC2 service can assume this role.
# ------------------------------------------------------------

data "aws_iam_policy_document" "ec2_assume_role" {

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}


# ------------------------------------------------------------
# 2. CREATE EC2 IAM ROLE
#
# Creates a role that EC2 instances can assume.
# No permanent AWS access keys are required.
# ------------------------------------------------------------

resource "aws_iam_role" "ec2_role" {

  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = var.ssm_policy_arn
}


resource "aws_iam_role_policy_attachment" "cloudwatch" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = var.cloudwatch_policy_arn
}


resource "aws_iam_instance_profile" "ec2_profile" {

  name = "${var.project_name}-${var.environment}-ec2-profile"

  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-profile"
    Project     = var.project_name
    Environment = var.environment
  }
}