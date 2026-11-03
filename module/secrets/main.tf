# ==========================================
# SEC-002: Least-Privilege Secrets Access
# ==========================================

data "aws_iam_policy_document" "approved_secrets" {
  count = length(var.approved_secret_arns) > 0 ? 1 : 0

  statement {
    sid    = "ReadApprovedSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = var.approved_secret_arns
  }
}

resource "aws_iam_role_policy" "approved_secrets" {
  count = length(var.approved_secret_arns) > 0 ? 1 : 0

  name   = "${var.project_name}-${var.environment}-secrets-read"
  role   = var.ec2_role_name
  policy = data.aws_iam_policy_document.approved_secrets[0].json
}