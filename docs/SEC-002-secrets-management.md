
# SEC-002: AWS Secrets Management

## Project
UTC Student Services Portal

Environment: Development (dev)

## Objective
Securely manage application credentials using AWS Secrets Manager
and provide least-privilege access through the EC2 IAM role.

## Current Implementation
- Terraform module: module/secrets
- Existing IAM role: utc-app-dev-ec2-role
- Approved secret ARNs: Empty list
- Secret-read permissions: Not deployed
- Application-specific secrets: Not created
- Terraform validation: Successful
- Terraform plan: No new IAM or Secrets Manager resources

## Existing RDS Secret Configuration
The RDS Terraform module uses:

manage_master_user_password = true

When RDS is enabled and created, AWS will manage the database
master password in Secrets Manager.

RDS is currently disabled. The application should normally use
a separate, least-privileged database user rather than the
master account.

## How the Application Will Retrieve Secrets

1. The application runs on an EC2 instance with an IAM instance profile.
2. The application receives the approved secret ARN as configuration.
3. The AWS SDK obtains temporary credentials from the EC2 IAM role.
4. The application calls Secrets Manager GetSecretValue.
5. AWS IAM checks permission for the requested secret ARN.
6. The application uses the returned value in memory without logging it.

Example Python code (for future implementation):

```python
import os
import boto3

client = boto3.client("secretsmanager", region_name="us-east-1")

response = client.get_secret_value(
    SecretId=os.environ["UTC_APP_SECRET_ARN"]
)

secret_value = response["SecretString"]

# Use the secret securely. Do not print or log its value.
```

The application must have boto3 installed, and the secret ARN
must be provided through deployment configuration.

## IAM Security Controls

The Secrets module grants only:

- secretsmanager:GetSecretValue
- secretsmanager:DescribeSecret

Permissions are restricted to approved secret ARNs.

When approved_secret_arns is empty, no additional IAM policy
is created.

A customer-managed KMS key may require a separately scoped
kms:Decrypt permission.

## Network Requirements

EC2 instances in private subnets need network connectivity
to the regional AWS Secrets Manager endpoint.

Options include:
- An interface VPC endpoint for Secrets Manager
- NAT-based outbound connectivity

NAT is currently disabled for this project. Connectivity must
be configured and verified before runtime secret retrieval.

## Pending Application Team Requirements

- Identify required application secrets.
- Confirm the database application-user credentials.
- Approve the exact secret ARNs.
- Confirm secret rotation requirements.
- Confirm private-subnet network access.
- Test runtime retrieval without exposing secret values.

## Deployment Status

Configuration and validation completed.

No application secrets or additional Secrets Manager IAM
permissions have been deployed for SEC-002.

Do not deploy until requirements and the Terraform execution
plan have been reviewed and approved.
