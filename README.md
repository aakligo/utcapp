
# UTC Student Services Portal — AWS Infrastructure

## Project Overview

This repository contains Terraform Infrastructure as Code (IaC)
for the UTC Student Services Portal.

The portal is designed to support student enrollment status,
document uploads, lab access requests, support requests,
and course information.

## AWS Architecture

Planned application traffic flow:

User → Route 53 → HTTPS (ACM) → Application Load Balancer
→ EC2 Auto Scaling Group → Amazon RDS PostgreSQL

Supporting services:

- Amazon VPC and networking
- IAM roles and instance profiles
- Amazon S3 for student documents
- Amazon EFS when shared storage is required
- AWS Secrets Manager
- Amazon CloudWatch
- Amazon SNS

## Terraform Project Structure

```text
utcapp-clean/
├── envs/
│   ├── dev/
│   └── prod/
├── module/
│   ├── network/
│   ├── security-groups/
│   ├── acm/
│   ├── alb/
│   ├── compute/
│   ├── database/
│   ├── storage/
│   ├── iam/
│   ├── secrets/
│   └── monitoring/
├── docs/
├── .gitignore
└── README.md
```

## AWS Region

Primary deployment region: us-east-1

The network spans three Availability Zones.

## Infrastructure Status

| Ticket | Description | Status |
|--------|-------------|--------|
| NET-001 | VPC, subnets, routing | Deployed |
| SEC-001 | Security groups | Deployed |
| ING-001 | ACM, ALB, Route 53 | Partially deployed |
| CMP-001 | EC2 launch template and ASG | Deployed, capacity zero |
| DB-001 | RDS PostgreSQL | Configured, disabled |
| STO-001 | S3 and optional EFS | Configured, disabled |
| IAM-001 | EC2 IAM permissions | Deployed |
| SEC-002 | Secrets management | Configured, awaiting requirements |
| OBS-001 | CloudWatch and SNS | Configured, disabled |
| IAC-001 | Documentation | In progress |

## Security

- EC2 application servers are designed for private subnets.
- Security groups restrict application and database access.
- EC2 uses an IAM instance profile.
- Secrets Manager permissions are restricted to approved ARNs.
- RDS is configured for encrypted storage and AWS-managed
  master credentials when enabled.
- S3 is configured for private access and encryption.

Never commit passwords, private keys, AWS credentials,
or Terraform state files.

## Cost Controls

The development environment currently uses:

- Auto Scaling Group desired capacity: 0
- NAT Gateway: disabled
- ALB: disabled
- RDS: disabled
- S3 and EFS: disabled
- Monitoring resources: disabled

Some foundational AWS resources, including Route 53 and ACM,
already exist. Review AWS billing before additional deployment.

## Terraform Workflow

Run commands from the development environment:

```bash
cd envs/dev

terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Review the Terraform plan before deployment.

Do not run terraform apply until the planned changes,
resource dependencies, security, and AWS costs are approved.

## Remaining Work

- Finish infrastructure documentation and outputs.
- Confirm application secret requirements.
- Configure application log delivery.
- Confirm private-subnet access to AWS service endpoints.
- Review deployment dependencies and costs.
- Deploy approved application resources.
- Test health checks, monitoring, database connectivity,
  and application functionality.
