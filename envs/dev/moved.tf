# INC-002: Preserve listener rule state addresses.

moved {
  from = aws_lb_listener_rule.auth_test
  to   = aws_lb_listener_rule.auth_test[0]
}

moved {
  from = aws_lb_listener_rule.auth_me
  to   = aws_lb_listener_rule.auth_me[0]
}

moved {
  from = aws_lb_listener_rule.students
  to   = aws_lb_listener_rule.students[0]
}

moved {
  from = aws_lb_listener_rule.login
  to   = aws_lb_listener_rule.login[0]
}

moved {
  from = aws_lb_listener_rule.students_post
  to   = aws_lb_listener_rule.students_post[0]
}

moved {
  from = aws_lb_listener_rule.service_requests
  to   = aws_lb_listener_rule.service_requests[0]
}
