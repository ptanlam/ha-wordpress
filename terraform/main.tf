module "ansible_playbook_bucket" {
  source = "./modules/ansible_playbook_bucket"

  name            = "${var.app_name}-playbook-${var.environment}"
  replica_enabled = var.playbook_bucket.replica_enabled

  providers = {
    aws.main    = aws.main
    aws.replica = aws.failover
  }
}

module "networking" {
  source = "./modules/networking"

  vpc_name = "${var.app_name}-${var.environment}"

  cidr = var.vpc.cidr
  azs  = var.vpc.azs

  private_subnets  = var.vpc.private_subnets
  public_subnets   = var.vpc.public_subnets
  database_subnets = var.vpc.database_subnets

  enable_nat_gateway     = var.vpc.enable_nat_gateway
  one_nat_gateway_per_az = var.vpc.one_nat_gateway_per_az

  providers = {
    aws = aws.main
  }
}

module "webserver_image" {
  source = "./modules/webserver_image"

  name            = "${var.app_name}-${var.environment}"
  playbook_bucket = module.ansible_playbook_bucket.bucket_name

  providers = {
    aws = aws.main
  }
}
