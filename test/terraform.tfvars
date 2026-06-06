vpc_name = "terraform-test"
vpc_cidr = "10.0.0.0/16"
environment = "dev"

public_subnet_data = [
  { cidr = "10.0.1.0/24", availability_zone = "us-east-1a", prefix = "pub"},
  { cidr = "10.0.2.0/24", availability_zone = "us-east-1b", prefix = "pub"}
]

private_subnet_data = [
    { cidr = "10.0.3.0/24", availability_zone = "us-east-1a", prefix = "pvt"},
    { cidr = "10.0.4.0/24", availability_zone = "us-east-1b", prefix = "pvt"}
]

need_nat_gateway = true
need_single_nat_gateway = false