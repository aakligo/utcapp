# Day 01 - AWS Network Infrastructure

## Ticket Information

- Project: UTC Student Services Portal
- Ticket: NET-001
- Date: November 26, 2026
- Role: DevOps Engineer
- Environment: Development
- Status: Daily assignment completed

## Objective

Review the existing AWS network infrastructure
and improve Terraform configuration reliability.

## Activities Completed

- Reviewed network infrastructure requirements.
- Created a dedicated Git feature branch.
- Reviewed Terraform network module structure.
- Implemented IPv4 /16 CIDR input validation.
- Executed positive and negative functional tests.
- Verified the deployed VPC using AWS CLI.
- Verified nine subnets across three Availability Zones.
- Verified VPC DNS support and DNS hostnames.

## Technical Improvement

Added Terraform variable validation using:

- can()
- cidrnetmask()
- endswith()

This prevents unsupported VPC CIDR configurations
from proceeding to infrastructure deployment.

## Test Results

| Test | Input | Result |
|------|-------|--------|
| TC-001 | 10.0.0.0/16 | Passed |
| TC-002 | hello | Passed |
| TC-003 | 10.0.0.0/24 | Passed |
| TC-004 | 10.0.0.0/33 | Passed |
| TC-005 | 2001:db8::/16 | Passed |

Total tests: 5
Passed: 5
Success rate: 100%

## Infrastructure Verification

- Region: us-east-1
- VPC CIDR: 10.0.0.0/16
- Availability Zones: 3
- Public subnets: 3
- Application subnets: 3
- Database subnets: 3
- DNS support: Enabled
- DNS hostnames: Enabled

## Terraform Validation

- Terraform fmt: Passed
- Terraform validate: Passed
- Terraform plan: No changes
- Terraform exit code: 0

## Skills Practiced

- AWS Networking
- Terraform
- Infrastructure as Code
- Git and GitHub
- AWS CLI
- Python scripting
- Input validation
- Infrastructure auditing

## Lessons Learned

Input validation helps prevent configuration errors.
Negative tests pass when invalid inputs are correctly
rejected.

Terraform validation and planning should be performed
before infrastructure deployment.

## Next Steps

- Review network architecture and CIDR calculations.
- Verify Internet Gateway.
- Verify route tables and subnet associations.
- Verify NAT Gateway configuration.
- Verify S3 Gateway Endpoint.

## Blockers

No known blockers.

## Conclusion

Day 1 completed successfully.
NET-001 remains in progress.
No deployed AWS resources were modified.
