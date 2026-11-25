# ==========================================
# AUTH-002: Protected ALB authentication test
# ==========================================

resource "aws_lb_listener_rule" "auth_test" {
  listener_arn = module.alb[0].https_listener_arn
  priority     = 10

  action {
    type  = "authenticate-cognito"
    order = 1

    authenticate_cognito {
      user_pool_arn       = module.auth.user_pool_arn
      user_pool_client_id = module.auth.alb_client_id
      user_pool_domain    = module.auth.domain

      on_unauthenticated_request = "authenticate"
      scope                      = "openid email profile"
      session_cookie_name        = "AWSELBAuthSessionCookie"
      session_timeout            = 3600
    }
  }

  action {
    type  = "fixed-response"
    order = 2

    fixed_response {
      content_type = "text/plain"
      message_body = "UTC authentication successful"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/auth-test"]
    }
  }
}
