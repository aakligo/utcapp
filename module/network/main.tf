# This locals block creates reusable values inside the module.
# Terraform automatically calculates subnet names, CIDR blocks,
# Availability Zones, and subnet types.
# This helps us avoid writing nine separate aws_subnet resources.
# It makes our Terraform code cleaner, shorter, and easier to maintain.

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    var.az_count
  )

  subnet_tiers = {
    public = {
      offset = 0
      public = true
    }

    app = {
      offset = 10
      public = false
    }

    database = {
      offset = 20
      public = false
    }
  }

  subnets = merge([
    for tier, config in local.subnet_tiers : {
      for index, az in local.availability_zones :
      "${tier}-${index + 1}" => {
        cidr   = cidrsubnet(var.vpc_cidr, 8, config.offset + index)
        az     = az
        tier   = tier
        public = config.public
      }
    }
  ]...)

  public_subnets = {
    for key, subnet in local.subnets :
    key => subnet if subnet.tier == "public"
  }

  app_subnets = {
    for key, subnet in local.subnets :
    key => subnet if subnet.tier == "app"
  }

  database_subnets = {
    for key, subnet in local.subnets :
    key => subnet if subnet.tier == "database"
  }
}
// Create the VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}
// Create the subnets
resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "${local.name_prefix}-${each.key}"
    Tier = each.value.tier
  }
}
// Create the Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}
// Create the public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-eip"
  }
}
// Create the NAT Gateway
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.this["public-1"].id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${local.name_prefix}-nat"
  }
}
//
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-app-rt"
  }

}
resource "aws_route" "app_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "app" {
  for_each = local.app_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.app.id
}

// Create the database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-database-rt"
  }
}

resource "aws_route_table_association" "database" {
  for_each = local.database_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.database.id
}
