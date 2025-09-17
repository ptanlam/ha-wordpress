locals {
  main_bucket_name    = var.name
  replica_bucket_name = "${var.name}-replica"
}

module "main" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = local.main_bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  replication_configuration = var.replica_enabled ? {
    role = module.replication_role.arn

    rule = {
      id = "replica_all_rule"

      status = "Enabled"

      destination = {
        bucket        = module.replica.s3_bucket_arn
        storage_class = "STANDARD"
      }
    }
  } : {}

  providers = {
    aws = aws.main
  }
}

module "replica" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = local.replica_bucket_name
  acl    = "private"

  create_bucket = var.replica_enabled

  versioning = {
    enabled = true
  }

  providers = {
    aws = aws.replica
  }
}
