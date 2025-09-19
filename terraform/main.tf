module "buckets" {
  source = "./modules/buckets"

  name = "${var.app_name}-${var.environment}"

  providers = {
    aws.main    = aws.main
    aws.replica = aws.failover
  }
}

module "iam" {
  source = "./modules/iam"

  name_prefix = "${var.app_name}-${var.environment}"

  playbook_bucket         = module.buckets.ansible_playbook_bucket_name
  playbook_bucket_replica = module.buckets.ansible_playbook_bucket_replica_name
  playbook_bucket_logs    = module.buckets.image_builder_logs_bucket_name

  providers = {
    aws = aws.main
  }
}

module "networking_main" {
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

module "networking_replica" {
  source = "./modules/networking"

  vpc_name = "${var.app_name}-${var.environment}"

  cidr = var.vpc.cidr
  azs  = var.vpc.failover_azs

  private_subnets  = var.vpc.private_subnets
  public_subnets   = var.vpc.public_subnets
  database_subnets = var.vpc.database_subnets

  enable_nat_gateway     = var.vpc.enable_nat_gateway
  one_nat_gateway_per_az = var.vpc.one_nat_gateway_per_az

  providers = {
    aws = aws.failover
  }
}

module "database" {
  source = "./modules/database"

  depends_on = [module.networking_main]

  identifier        = "${var.app_name}-${var.environment}"
  instance_class    = var.database.instance_class
  allocated_storage = var.database.allocated_storage
  db_name           = var.database.db_name
  username          = var.database.username
  password          = var.database.password

  main_networking = {
    vpc_id     = module.networking_main.vpc_id
    vpc_cidr   = module.networking_main.vpc_cidr
    subnet_ids = module.networking_main.database_subnets
  }

  replica_networking = {
    vpc_id     = module.networking_replica.vpc_id
    vpc_cidr   = module.networking_replica.vpc_cidr
    subnet_ids = module.networking_replica.database_subnets
  }

  providers = {
    aws.main    = aws.main
    aws.replica = aws.failover
  }
}

module "webserver_image_main" {
  source = "./modules/webserver_image"

  depends_on = [module.buckets, module.networking_main, module.database]

  name = "${var.app_name}-${var.environment}"

  playbook_bucket     = module.buckets.ansible_playbook_bucket_name
  logging_bucket_name = module.buckets.image_builder_logs_bucket_name

  vpc_id          = module.networking_main.vpc_id
  private_subnets = module.networking_main.private_subnets

  instance_profile_name = module.iam.image_builder_instance_profile_name

  db_host     = module.database.main_db_host
  db_name     = var.database.db_name
  db_user     = var.database.username
  db_password = var.database.password

  providers = {
    aws = aws.main
  }
}

module "webserver_image_replica" {
  source = "./modules/webserver_image"

  depends_on = [module.buckets, module.networking_replica, module.database]

  name = "${var.app_name}-${var.environment}"

  playbook_bucket     = module.buckets.ansible_playbook_bucket_name
  logging_bucket_name = module.buckets.image_builder_logs_bucket_name

  vpc_id          = module.networking_replica.vpc_id
  private_subnets = module.networking_replica.private_subnets

  instance_profile_name = module.iam.image_builder_instance_profile_name

  db_host     = module.database.replica_db_host
  db_name     = var.database.db_name
  db_user     = var.database.username
  db_password = var.database.password

  providers = {
    aws = aws.failover
  }
}

module "webservers_main" {
  source = "./modules/webservers"

  depends_on = [module.webserver_image_main, module.iam]

  name          = "${var.app_name}-${var.environment}"
  instance_type = var.webserver.instance_type

  vpc_id          = module.networking_main.vpc_id
  private_subnets = module.networking_main.private_subnets
  public_subnets  = module.networking_main.public_subnets

  desired_capacity = var.webserver.desired_capacity
  max_size         = var.webserver.max_size
  min_size         = var.webserver.min_size

  instance_profile_name = module.iam.webserver_instance_profile_name

  providers = {
    aws = aws.main
  }
}

module "webservers_replica" {
  source = "./modules/webservers"

  depends_on = [module.webserver_image_replica, module.iam]

  name          = "${var.app_name}-${var.environment}"
  instance_type = var.webserver.instance_type

  vpc_id          = module.networking_replica.vpc_id
  private_subnets = module.networking_replica.private_subnets
  public_subnets  = module.networking_replica.public_subnets

  desired_capacity = var.webserver.desired_capacity
  max_size         = var.webserver.max_size
  min_size         = var.webserver.min_size

  instance_profile_name = module.iam.webserver_instance_profile_name

  providers = {
    aws = aws.failover
  }
}

module "dns" {
  source = "./modules/dns"

  depends_on = [module.webservers_main, module.webservers_replica]

  name = var.dns_name

  main_alb_dns         = module.webservers_main.dns_name
  main_alb_zone_id     = module.webservers_main.zone_id
  failover_alb_dns     = module.webservers_replica.dns_name
  failover_alb_zone_id = module.webservers_replica.zone_id

  providers = {
    aws = aws.main
  }
}
