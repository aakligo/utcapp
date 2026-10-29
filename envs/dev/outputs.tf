output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "app_subnet_ids" {
  value = module.network.app_subnet_ids
}

output "database_subnet_ids" {
  value = module.network.database_subnet_ids
}

output "availability_zones" {
  value = module.network.availability_zones
}