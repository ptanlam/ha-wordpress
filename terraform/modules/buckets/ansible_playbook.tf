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

resource "aws_s3_object" "ansible" {
  depends_on = [module.ansible_playbook_bucket]

  for_each = fileset("../ansible/", "**")

  bucket = module.ansible_playbook_bucket.s3_bucket_id
  key    = each.value
  source = "../ansible/${each.value}"
  etag   = filemd5("../ansible/${each.value}")
}
