
//Create module/network/output.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"

  value = [
    for key in ["public-1", "public-2", "public-3"] :
    aws_subnet.this[key].id
    if contains(keys(aws_subnet.this), key)
  ]
}

output "app_subnet_ids" {
  description = "IDs of private application subnets"

  value = [
    for key in ["app-1", "app-2", "app-3"] :
    aws_subnet.this[key].id
    if contains(keys(aws_subnet.this), key)
  ]
}

output "database_subnet_ids" {
  description = "IDs of private database subnets"

  value = [
    for key in ["database-1", "database-2", "database-3"] :
    aws_subnet.this[key].id
    if contains(keys(aws_subnet.this), key)
  ]
}

output "availability_zones" {
  description = "Selected Availability Zones"
  value       = local.availability_zones
}