
# STO-001: Amazon S3 Application Storage

resource "aws_s3_bucket" "this" {
  count = var.enable_s3 ? 1 : 0

  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Project     = var.project_name
    Environment = var.environment
    Purpose     = "UTC Student Services Portal Storage"
  }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "this" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
# STO-001: S3 Server-Side Encryption

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# STO-001: S3 Bucket Versioning


resource "aws_s3_bucket_versioning" "this" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# STO-001: S3 Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    id     = "cleanup-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
# ==========================================
# STO-001: EFS Security Group
# ==========================================

resource "aws_security_group" "efs" {
  count = var.enable_efs ? 1 : 0

  name        = "${var.project_name}-${var.environment}-efs-sg"
  description = "Security group for UTC EFS"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-efs-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Allow NFS traffic from EC2 application servers
resource "aws_vpc_security_group_ingress_rule" "efs_from_app" {
  count = var.enable_efs ? 1 : 0

  security_group_id            = aws_security_group.efs[0].id
  referenced_security_group_id = var.app_security_group_id

  from_port   = 2049
  to_port     = 2049
  ip_protocol = "tcp"

  description = "Allow NFS from EC2 application servers"
}

# Allow EC2 application servers to reach EFS
resource "aws_vpc_security_group_egress_rule" "app_to_efs" {
  count = var.enable_efs ? 1 : 0

  security_group_id            = var.app_security_group_id
  referenced_security_group_id = aws_security_group.efs[0].id

  from_port   = 2049
  to_port     = 2049
  ip_protocol = "tcp"

  description = "Allow NFS traffic to EFS"
}
# ==========================================
# STO-001: Encrypted Amazon EFS
# ==========================================

resource "aws_efs_file_system" "this" {
  count = var.enable_efs ? 1 : 0

  creation_token   = "${var.project_name}-${var.environment}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"

  tags = {
    Name        = "${var.project_name}-${var.environment}-efs"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# EFS Mount Targets in Private App Subnets
# ==========================================

resource "aws_efs_mount_target" "this" {
  count = var.enable_efs ? length(var.private_subnet_ids) : 0

  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs[0].id]
}
# STO-001: Deny unencrypted HTTP requests to S3
resource "aws_s3_bucket_policy" "https_only" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.this[0].arn,
          "${aws_s3_bucket.this[0].arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}