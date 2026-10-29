terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = local.aws_region
}

locals {
  aws_region         = "us-east-1"
  project_name       = "utc-app"
  environment        = "dev"
  vpc_cidr           = "10.0.0.0/16"
  az_count           = 3
  enable_nat_gateway = false
}
