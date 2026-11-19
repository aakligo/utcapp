# SEC-002: Application database secret access

data "aws_secretsmanager_secret" "db_app" {
  name = "utc-app-dev-db-app-credentials"
}

data "aws_iam_policy_document" "db_app_secret" {
  statement {
    sid    = "ReadApplicationDatabaseCredentials"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      data.aws_secretsmanager_secret.db_app.arn
    ]
  }
}

resource "aws_iam_role_policy" "db_app_secret" {
  name = "${var.project_name}-${var.environment}-db-app-secret-read"

  role = module.iam.ec2_role_name

  policy = data.aws_iam_policy_document.db_app_secret.json
}
