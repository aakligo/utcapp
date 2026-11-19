# STO-001: S3 permissions for UTC Python backend

data "aws_iam_policy_document" "student_documents" {
  count = var.enable_s3 ? 1 : 0

  statement {
    sid    = "ListStudentDocuments"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      module.storage.s3_bucket_arn
    ]
  }

  statement {
    sid    = "ReadWriteStudentDocuments"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${module.storage.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "student_documents" {
  count = var.enable_s3 ? 1 : 0

  name   = "${var.project_name}-${var.environment}-s3-student-documents"
  role   = module.iam.ec2_role_name
  policy = data.aws_iam_policy_document.student_documents[0].json
}
