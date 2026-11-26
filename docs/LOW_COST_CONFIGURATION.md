# Low-Cost Development Configuration

## Terraform Settings

    enable_nat_gateway = false
    enable_alb = false
    enable_rds = false
    enable_s3 = true
    enable_efs = false
    desired_capacity = 0
    enable_ssm_endpoints = false
    enable_cloudwatch_logs_endpoint = false
    enable_secretsmanager_endpoint = false
    enable_cloudwatch = false

## Operational Guidelines

- Keep the application offline when not in use.
- Enable services only when required by a ticket.
- Review Terraform plans before applying changes.
- Retain the RDS recovery snapshot.
- Monitor AWS billing regularly.
- Never commit Terraform state or sensitive variables.
