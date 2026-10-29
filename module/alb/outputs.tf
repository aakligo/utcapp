# ==========================================
# APPLICATION LOAD BALANCER MODULE OUTPUTS
# Project: UTC App
# ==========================================

# ALB ARN
# Used to identify the ALB in AWS
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}

# ALB DNS Name
# Used to access the application through a browser
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

# ALB Target Group ARN
# Used when registering application servers
output "target_group_arn" {
  description = "ARN of the application target group"
  value       = aws_lb_target_group.app.arn
}

# ALB Zone ID
# Used later when configuring Route 53 DNS
output "alb_zone_id" {
  description = "Route 53 hosted zone ID of the ALB"
  value       = aws_lb.this.zone_id
}
