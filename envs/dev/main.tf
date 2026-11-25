module "network" {
  source = "../../module/network"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  enable_nat_gateway = var.enable_nat_gateway
}


module "security_groups" {
  source = "../../module/security-groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.network.vpc_id

  app_port = 3000
  db_port  = 5432
}

module "alb" {
  source = "../../module/alb"


  count = var.enable_alb ? 1 : 0

  project_name = var.project_name
  environment  = var.environment

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  alb_security_group_id = module.security_groups.alb_security_group_id

  app_port        = 3000
  certificate_arn = module.acm.certificate_arn
}

module "acm" {
  source         = "../../module/acm"
  domain_name    = "utc.triplearides.com"
  hosted_zone_id = "Z004138513LCBZH23PN39"
  project_name   = var.project_name
  environment    = var.environment

}
resource "aws_route53_record" "utc_app" {
  count   = var.enable_alb ? 1 : 0
  zone_id = "Z004138513LCBZH23PN39"
  name    = "utc.triplearides.com"
  type    = "A"

  alias {
    name                   = module.alb[0].alb_dns_name
    zone_id                = module.alb[0].alb_zone_id
    evaluate_target_health = false
  }
}

module "iam" {
  source = "../../module/iam"

  project_name = var.project_name
  environment  = var.environment
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "compute" {
  source = "../../module/compute"

  project_name = var.project_name
  environment  = var.environment


  ami_id             = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type      = "t3.micro"
  private_subnet_ids = module.network.app_subnet_ids

  app_security_group_id = module.security_groups.app_security_group_id

  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  s3_bucket_name            = var.enable_s3 ? module.storage.s3_bucket_name : ""
  auth_alb_arn              = module.alb[0].alb_arn
  auth_client_id            = module.auth.alb_client_id
  # DB-001: RDS PostgreSQL secret
  db_secret_arn = var.enable_rds ? data.aws_secretsmanager_secret.db_app.arn : ""

  db_host          = var.enable_rds ? split(":", module.database[0].db_endpoint)[0] : ""
  min_size         = 0
  desired_capacity = 1
  max_size         = 3


  target_group_arns = var.enable_alb ? [module.alb[0].target_group_arn] : []
}

# ==========================================
# DB-001: Amazon RDS PostgreSQL
# ==========================================

module "database" {
  count  = var.enable_rds ? 1 : 0
  source = "../../module/database"

  project_name = var.project_name
  environment  = var.environment

  database_subnet_ids   = module.network.database_subnet_ids
  rds_security_group_id = module.security_groups.rds_security_group_id

  db_name           = "utcapp"
  db_username       = "utcadmin"
  db_instance_class = "db.t3.micro"
  allocated_storage = 20
} # ==========================================
# STO-001: S3 and EFS Storage
# ==========================================

module "storage" {
  source = "../../module/storage"

  project_name = var.project_name
  environment  = var.environment

  enable_s3  = var.enable_s3
  enable_efs = var.enable_efs

  s3_bucket_name = "${var.project_name}-${var.environment}-student-documents"

  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.app_subnet_ids
  app_security_group_id = module.security_groups.app_security_group_id
}

# SEC-002: Secrets Management
module "secrets" {
  source = "../../module/secrets"

  project_name = var.project_name
  environment  = var.environment

  ec2_role_name = module.iam.ec2_role_name

  # SEC-002: Approved application database secret
  approved_secret_arns = var.enable_rds ? [data.aws_secretsmanager_secret.db_app.arn] : []
}
# OBS-001: CloudWatch Monitoring and SNS
module "monitoring" {
  source = "../../module/monitoring"

  project_name = var.project_name
  environment  = var.environment

  # Keep monitoring disabled until deployment approval
  enable_monitoring = true

  # Reuse the existing EC2 Auto Scaling Group
  autoscaling_group_name = module.compute.autoscaling_group_name

  # Monitoring settings
  cpu_threshold      = 80
  log_retention_days = 7
  notification_email = "akligoatsu83@gmail.com"
}
module "vpc_endpoints" {
  source = "../../module/vpc-endpoints"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  enable_cloudwatch_logs_endpoint = true
  enable_secretsmanager_endpoint  = true
  vpc_id                          = module.network.vpc_id

  private_subnet_ids = [
    module.network.app_subnet_ids[0]
  ]
  app_security_group_id = module.security_groups.app_security_group_id
  app_route_table_id    = module.network.app_route_table_id
}

# Allow application EC2 instances to access SSM VPC endpoints
resource "aws_vpc_security_group_egress_rule" "app_to_ssm_endpoints" {
  security_group_id = module.security_groups.app_security_group_id

  referenced_security_group_id = module.vpc_endpoints.endpoint_security_group_id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow HTTPS traffic to SSM VPC endpoints"

}

# ==========================================
# AUTH-001: Amazon Cognito Student Authentication
# ==========================================

module "auth" {
  source = "../../module/auth"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  callback_url = "https://utc.triplearides.com/"
  logout_url   = "https://utc.triplearides.com/"
}

