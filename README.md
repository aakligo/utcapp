
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

---

## Incident INC-001: AWS ALB Target Unhealthy — Backend Application Failure

**Project:** UTC Student Services Portal  
**Date:** November 17, 2026  
**Environment:** AWS Development (us-east-1)  
**Category:** DevOps / AWS / Linux Incident  
**Priority:** P3 — Medium (Development)  
**Status:** Resolved — Preventive Action Pending

### Incident Summary

During deployment testing of the UTC Student Services Portal, the AWS Application Load Balancer (ALB) reported an unhealthy EC2 target even though the EC2 instance was running and the Auto Scaling Group considered it healthy.

The Python backend application was not responding on port 3000, causing the ALB health checks to fail.

### Technologies Involved

- AWS EC2 — Amazon Linux 2023
- AWS Application Load Balancer and Target Groups
- AWS Auto Scaling Group
- AWS Systems Manager (SSM)
- Linux systemd and journalctl
- Python HTTP application
- Terraform Infrastructure as Code
- Amazon CloudWatch

### Incident Symptoms

| Component | Initial Status |
|---|---|
| EC2 instance | Healthy |
| Auto Scaling Group | InService |
| ALB target | Unhealthy |
| Python service | Inactive |
| Application port 3000 | Not listening |
| HTTP health endpoint | Failed |

**AWS Error:** `Target.FailedHealthChecks`

### Troubleshooting Investigation

#### 1. Checked ALB Target Health

Used AWS CLI to investigate the target group.

```bash
aws elbv2 describe-target-health \
  --region us-east-1 \
  --target-group-arn <TARGET_GROUP_ARN>
```

The target was registered but failed the ALB health checks.

#### 2. Verified Health Check Configuration

Confirmed the ALB settings:

- Protocol: HTTP
- Port: 3000
- Health check path: `/health`
- Successful status codes: 200–399

The target group configuration was correct.

#### 3. Checked EC2 and Systems Manager

Confirmed that the EC2 instance was running and AWS Systems Manager reported it as online.

Used SSM Run Command to investigate the private instance without enabling inbound SSH.

#### 4. Diagnosed the Application

Executed the following commands through AWS Systems Manager:

```bash
systemctl is-active utc-app.service
ss -lntp | grep :3000
curl -i http://127.0.0.1:3000/health
```

Initial findings:

- Application service was inactive.
- No Python process was listening on port 3000.
- Local HTTP health checks failed.

#### 5. Reviewed Linux systemd Logs

Inspected the service configuration and logs using `systemctl` and `journalctl`.

The output revealed:

```text
LoadState=bad-setting
ActiveState=inactive
Unknown section '[Service'. Ignoring.
Service has no ExecStart=. Refusing.
```

### Root Cause Analysis

The EC2 user-data startup script contained a malformed systemd section header.

**Incorrect:**

```ini
[[Service]
```

**Correct:**

```ini
[Service]
```

The additional opening bracket caused systemd to ignore the service configuration, including the `ExecStart` directive.

Consequently, the Python application did not start, and the ALB could not reach the application on port 3000.

### Resolution Implemented

1. Corrected the malformed `[Service]` header in the Terraform startup script.
2. Used AWS Systems Manager to repair the service file on the running EC2 instance.
3. Reloaded the systemd configuration.
4. Restarted the Python application service.
5. Verified that the service was running and listening on port 3000.
6. Tested the `/health` endpoint locally.
7. Confirmed that the ALB target returned to a healthy state.

**Recovery commands:**

```bash
sudo systemctl daemon-reload
sudo systemctl restart utc-app.service
systemctl is-active utc-app.service
curl -i http://127.0.0.1:3000/health
```

### Final Verification

| Component | Before | After |
|---|---|---|
| EC2 instance | Healthy | Healthy |
| Python application | Inactive | Active |
| Port 3000 | Not listening | Listening |
| Local health endpoint | Failed | HTTP 200 OK |
| ALB target health | Unhealthy | Healthy |

**Successful health response:**

```json
{
  "status": "healthy",
  "application": "UTC Student Services Portal",
  "environment": "dev"
}
```

**Final ALB target status:** `healthy`

### Preventive Actions

- [x] Identify the systemd configuration issue.
- [x] Correct the Terraform startup script source.
- [x] Repair the running EC2 application service.
- [x] Confirm HTTP 200 from the backend health endpoint.
- [x] Verify healthy ALB target registration.
- [ ] Deploy the corrected EC2 launch template through Terraform.
- [ ] Add automated systemd unit validation to CI/CD.
- [ ] Add automated application startup and health-check tests.
- [ ] Improve application startup monitoring and alerting.

### Lessons Learned

- A healthy EC2 instance does not guarantee application availability.
- ALB health checks help detect application-level failures.
- AWS Systems Manager enables secure troubleshooting of private EC2 instances.
- Linux systemd and journal logs are essential for root-cause analysis.
- Correcting both running infrastructure and Terraform source code helps prevent recurring incidents.
- Troubleshooting should isolate the application, operating system, and networking layers before making changes.

### Incident Outcome

**Successfully restored backend application availability and resolved the ALB health-check failure.**

This incident demonstrates hands-on experience with AWS troubleshooting, Linux service management, Terraform, application monitoring, and root-cause analysis.

