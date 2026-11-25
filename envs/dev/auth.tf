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

# ==========================================
# AUTH-003: Protected backend identity endpoint
# ==========================================

resource "aws_lb_listener_rule" "auth_me" {
  listener_arn = module.alb[0].https_listener_arn
  priority     = 20

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
    type             = "forward"
    order            = 2
    target_group_arn = module.alb[0].target_group_arn
  }

  condition {
    path_pattern {
      values = ["/auth/me"]
    }
  }
}

# ==========================================
# AUTH-005: Protected student endpoints
# ==========================================

resource "aws_lb_listener_rule" "students" {
  listener_arn = module.alb[0].https_listener_arn
  priority     = 30

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
    type             = "forward"
    order            = 2
    target_group_arn = module.alb[0].target_group_arn
  }

  condition {
    path_pattern {
      values = ["/students", "/students/*"]
    }
  }
}

# ==========================================
# AUTH-006: Browser login entry point
# ==========================================

resource "aws_lb_listener_rule" "login" {
  listener_arn = module.alb[0].https_listener_arn
  priority     = 5

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
    type  = "redirect"
    order = 2

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      host        = "#{host}"
      path        = "/"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/login"]
    }
  }
}

# ==========================================
# AUTH-006: AJAX-safe authenticated registration
# ==========================================

resource "aws_lb_listener_rule" "students_post" {
  listener_arn = module.alb[0].https_listener_arn
  priority     = 25

  action {
    type  = "authenticate-cognito"
    order = 1

    authenticate_cognito {
      user_pool_arn       = module.auth.user_pool_arn
      user_pool_client_id = module.auth.alb_client_id
      user_pool_domain    = module.auth.domain

      on_unauthenticated_request = "deny"
      scope                      = "openid email profile"
      session_cookie_name        = "AWSELBAuthSessionCookie"
      session_timeout            = 3600
    }
  }

  action {
    type             = "forward"
    order            = 2
    target_group_arn = module.alb[0].target_group_arn
  }

  condition {
    path_pattern {
      values = ["/students"]
    }
  }

  condition {
    http_request_method {
      values = ["POST"]
    }
  }
}
