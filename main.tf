# Create VPC

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = local.common_tags
}

# Create public subnets
resource "aws_subnet" "pub_subnet" {
    # 1. Loop through your local map at the resource level
    for_each = local.public_subnet_map
    
    vpc_id = aws_vpc.vpc.id

    # 2. Reference the current item's data from the map

    cidr_block = each.key
    availability_zone = each.value.availability_zone

    tags = local.common_tags
}

# Create private subnets
resource "aws_subnet" "pvt_subnet" {
    # 1. Loop through your local map at the resource level
    for_each = local.private_subnet_map

    vpc_id = aws_vpc.vpc.id

    # 2. Reference the current item's data from the map
    cidr_block = each.key
    availability_zone = each.value.availability_zone

    tags = local.common_tags
}

# Create internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = local.common_tags
}

# Create public route table
resource "aws_route_table" "pub_rt" {
    # No need to loop through the map, since a common route table is needed for all public subnets

    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = local.common_tags
}

