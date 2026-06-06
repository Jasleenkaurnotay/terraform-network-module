module "network_module" {
    source = "../"
    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr
    environment = var.environment
    public_subnet_data = var.public_subnet_data
    private_subnet_data = var.private_subnet_data
    need_nat_gateway = var.need_nat_gateway
    need_single_nat_gateway = var.need_single_nat_gateway
}