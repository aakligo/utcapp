# ==========================================
# APPLICATION LOAD BALANCER MODULE
# Project: UTC App
# ==========================================

# Common naming convention
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ==========================================
# 1. APPLICATION LOAD BALANCER
# ==========================================

resource "aws_lb" "this" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"

  # Reuse existing ALB security group
  security_groups = [var.alb_security_group_id]

  # Deploy ALB across existing public subnets
  subnets = var.public_subnet_ids

  # Prevent accidental deletion of ALB
  enable_deletion_protection = false

  tags = {
    Name        = "${local.name_prefix}-alb"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==========================================
# 2. APPLICATION TARGET GROUP
# ==========================================

resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Check whether application is healthy
  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${local.name_prefix}-tg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ==========================================
# 3. HTTP LISTENER
# ==========================================


# ==========================================
# HTTP LISTENER - REDIRECT TO HTTPS
# ==========================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ==========================================
# HTTPS LISTENER - PORT 443
# ==========================================

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"

  # Use the ACM certificate
  certificate_arn = var.certificate_arn

  # TLS security policy
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  # Forward requests to EC2 application servers
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}