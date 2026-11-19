# UTC Student Services Portal
## Final Infrastructure Audit

Environment: dev
AWS Region: us-east-1
Application: https://utc.triplearides.com/health

## Project Summary

The development infrastructure is operational and managed
using Terraform.

The application uses:
- AWS VPC with public, application and database subnets
- Application Load Balancer with HTTPS
- EC2 Auto Scaling Group and launch template
- Private Amazon RDS PostgreSQL
- Amazon S3 student document storage
- AWS IAM and Secrets Manager
- CloudWatch Logs and monitoring alarms
- Amazon SNS email notifications
- GitHub Actions CI

## Ticket Assessment

NET-001: Implemented; NAT Gateway disabled by design.
SEC-001: Security group rules verified.
ING-001: HTTPS, redirect and ALB health verified.
CMP-001: EC2 and ASG configured; replacement untested.
DB-001: RDS healthy, private, encrypted and backed up.
STO-001: S3 verified; EFS disabled by design.
IAM-001: Application permissions and trust reviewed.
SEC-002: Dedicated application database credentials verified.
OBS-001: CloudWatch logs and SNS email delivery verified.
IAC-001: Terraform validation and GitHub Actions CI passed.

## Verified Evidence

- Terraform validate: Success
- Terraform drift check: Exit code 0, no changes
- GitHub Actions CI: Passed
- ALB target: Healthy
- HTTP to HTTPS: 301 redirect
- HTTPS /health: Healthy
- PostgreSQL /db-health: Connected
- S3 upload and download: Previously tested
- RDS automated snapshots: Available and encrypted
- S3 public access: Blocked
- S3 encryption: AES256
- S3 versioning: Enabled
- S3 TLS-only policy: Enabled
- CloudWatch application log events: Confirmed
- SNS test email: Received

## Recovery Readiness

- ASG desired capacity: 1
- ASG launch template: $Latest
- Latest launch template version inspected: 15
- AMI: Amazon Linux 2023, available
- Existing instance: Healthy, InService
- Existing-instance DNF repository access: Passed

## Intentional Development Environment Exceptions

- NAT Gateway disabled for cost control
- EFS disabled for cost control
- RDS Multi-AZ disabled
- Single running EC2 instance

## Outstanding Production-Readiness Tests

- Actual EC2 instance replacement and bootstrap test
- RDS snapshot restoration test
- End-to-end CloudWatch alarm trigger test
- Full disaster recovery and load testing

## Conclusion

The core development infrastructure is operational and
suitable for technical demonstration.

Production readiness has not been certified. The documented
architecture exceptions and recovery tests remain open.
