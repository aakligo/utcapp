# SEC-002: Reference the existing application database secret.
# IAM access is managed by module.secrets in main.tf.
# Only retrieve the secret when RDS is enabled.

data "aws_secretsmanager_secret" "db_app" {
  count = var.enable_rds ? 1 : 0

  name = "utc-app-dev-db-app-credentials"
}
