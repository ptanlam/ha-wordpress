module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = var.vpc_name
  cidr = var.cidr

  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
}

module "vpc_endpoints" {
  depends_on = [module.vpc]

  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.0.1"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = []

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "${var.vpc_name}-s3-vpc-endpoint" }
    }
  }
}
