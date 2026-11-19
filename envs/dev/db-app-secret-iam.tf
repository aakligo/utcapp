# SEC-002: Reference the existing application database secret.
# IAM access is managed by module.secrets in main.tf.

data "aws_secretsmanager_secret" "db_app" {
  name = "utc-app-dev-db-app-credentials"
}