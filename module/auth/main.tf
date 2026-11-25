data "aws_caller_identity" "current" {}

locals {
  domain_prefix = lower(
    "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  )
}

resource "aws_cognito_user_pool" "this" {
  name = "${var.project_name}-${var.environment}-students"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  mfa_configuration = "OFF"

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cognito_user_pool_client" "web" {
  name         = "${var.project_name}-${var.environment}-web"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile"
  ]

  supported_identity_providers = ["COGNITO"]

  callback_urls = [
    var.callback_url
  ]

  logout_urls = [
    var.logout_url
  ]

  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 7

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = local.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}

# ==========================================
# AUTH-002: Cognito client for ALB authentication
# ==========================================

resource "aws_cognito_user_pool_client" "alb" {
  name         = "${var.project_name}-${var.environment}-alb"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile"
  ]

  supported_identity_providers = ["COGNITO"]

  callback_urls = [
    "https://utc.triplearides.com/oauth2/idpresponse"
  ]

  logout_urls = [
    "https://utc.triplearides.com/"
  ]

  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"
}
