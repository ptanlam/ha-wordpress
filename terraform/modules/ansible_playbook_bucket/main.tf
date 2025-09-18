locals {
  main_bucket_name    = var.name
  replica_bucket_name = "${var.name}-replica"

  tags = {
    Department = "Technology"
    Purpose    = "Ansible Playbook"
  }
}

module "main" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  create_bucket = !var.replica_enabled

  bucket = local.main_bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  tags = merge(local.tags, {
    Type = "Main"
  })

  providers = {
    aws = aws.main
  }
}

module "replica" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  create_bucket = var.replica_enabled

  bucket = local.replica_bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"


  versioning = {
    enabled = true
  }

  tags = merge(local.tags, {
    Type = "Replica"
  })

  providers = {
    aws = aws.replica
  }
}

module "main_with_replica" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  create_bucket = var.replica_enabled

  depends_on = [aws_iam_role.replication, module.replica]

  bucket = local.main_bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = {
      id = "replica_all"

      status = "Enabled"

      destination = {
        bucket        = module.replica.s3_bucket_arn
        storage_class = "STANDARD"
      }

      delete_marker_replication = "Enabled"
    }
  }

  tags = merge(local.tags, {
    Type = "Main"
  })

  providers = {
    aws = aws.main
  }
}
