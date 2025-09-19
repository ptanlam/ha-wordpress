locals {
  main_bucket_name    = "${var.name}-ansible-playbook"
  replica_bucket_name = "${local.main_bucket_name}-replica"

  tags = {
    Purpose = "Ansible Playbook"
  }
}
module "ansible_playbook_bucket_replica" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = local.replica_bucket_name

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

module "ansible_playbook_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  depends_on = [aws_iam_role.replication, module.ansible_playbook_bucket_replica]

  bucket = local.main_bucket_name

  versioning = {
    enabled = true
  }

  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = {
      id = "replica_all"

      status = "Enabled"

      destination = {
        bucket        = module.ansible_playbook_bucket_replica.s3_bucket_arn
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
