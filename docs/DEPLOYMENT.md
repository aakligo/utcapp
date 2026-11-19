# UTC Student Services Portal — AWS Deployment

## Environment
- Environment: dev
- AWS Region: us-east-1
- Infrastructure: Terraform
- Application: Python HTTP backend
- Repository: https://github.com/aakligo/utcapp

## Architecture
Route 53 -> ACM HTTPS -> Application Load Balancer
-> EC2 Auto Scaling Group -> Python Backend

Supporting services:
- VPC with public, private application, and database subnets
- Amazon RDS PostgreSQL
- Amazon S3 for student documents
- AWS Secrets Manager
- AWS Systems Manager
- CloudWatch Logs, alarms, and SNS
- IAM roles and security groups

## Application
Public health endpoint:
https://utc.triplearides.com/health

Internal endpoints:
- GET /db-health
- POST /documents
- GET /documents/{document-id}

Document upload and download tests passed.

## Deployment
Terraform directory: envs/dev

1. terraform init
2. terraform validate
3. terraform plan
4. Review the plan before applying
5. terraform apply

Never apply unreviewed changes to production resources.

## Deployment Configuration
- EC2 desired capacity: 1
- NAT Gateway: disabled
- EFS: disabled
- S3: enabled
- RDS: enabled

## Remaining Work
- Verify GitHub Actions workflow succeeds
- Complete IAM and database credential security review
- Confirm NAT and EFS requirements
- Finish application acceptance testing
- Complete final ticket sign-off
