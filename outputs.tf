output "vpc_id" {
    value = aws_vpc.vpc.id
    description = "VPC ID"
}

output "public_subnet_ids" {
    value = values(aws_subnet.pub_subnet)[*].id
    description = "List of all public subnets in the VPC"
}

output "private_subnet_ids" {
    value = values(aws_subnet.pvt_subnet)[*].id
    description = "List of all private subnets in the VPC"
}

output "nat_gateway_ids" {
    value = aws_nat_gateway.nat_gw[*].id
    description = "List of all Nat gateway IDs"
}