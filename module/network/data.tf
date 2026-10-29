// Create module/network/data.tf
// This file retrieves information that already exists in AWS.
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
