output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.web.id
}

output "domain" {
  value = aws_cognito_user_pool_domain.this.domain
}

output "login_base_url" {
  value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "alb_client_id" {
  value = aws_cognito_user_pool_client.alb.id
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.this.arn
}
