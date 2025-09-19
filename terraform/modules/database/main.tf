module "master" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  identifier = var.identifier

  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage

  db_name                     = var.db_name
  username                    = var.username
  password                    = var.password // should be stored in AWS Secrets Manager with replication enabled
  manage_master_user_password = false
  port                        = local.port

  vpc_security_group_ids = [aws_security_group.main.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  multi_az               = true
  create_db_subnet_group = true
  subnet_ids             = var.main_networking.subnet_ids
  db_subnet_group_name   = "${var.identifier}-subnet-group"

  # DB parameter group
  family = local.family

  # DB option group
  major_engine_version = local.major_engine_version

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]

  providers = {
    aws = aws.main
  }
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  description = "KMS key for cross region replica DB"

  # Aliases
  aliases                 = [var.identifier]
  aliases_use_name_prefix = true

  key_owners = [data.aws_caller_identity.current.id]

  providers = {
    aws = aws.replica
  }
}

module "replica" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  identifier = "${var.identifier}-replica"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db = module.master.db_instance_arn

  kms_key_id = module.kms.key_arn

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  port = local.port

  password = var.password

  multi_az = false

  create_db_subnet_group = true
  subnet_ids             = var.replica_networking.subnet_ids
  db_subnet_group_name   = "${var.identifier}-subnet-group"

  vpc_security_group_ids = [aws_security_group.replica.id]

  maintenance_window              = "Tue:00:00-Tue:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  providers = {
    aws = aws.replica
  }
}
