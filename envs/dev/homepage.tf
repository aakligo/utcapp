# Phase 2: UTC Student Services Portal homepage

resource "aws_s3_object" "homepage" {
  count = var.enable_s3 ? 1 : 0

  bucket       = module.storage.s3_bucket_name
  key          = "application/index.html"
  source       = "${path.module}/../../frontend/index.html"
  etag         = filemd5("${path.module}/../../frontend/index.html")
  content_type = "text/html"
}
