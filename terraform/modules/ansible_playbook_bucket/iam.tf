module "replication_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.1"

  create = var.replica_enabled

  name            = "${var.name}-bucket-replication-role"
  use_name_prefix = false

  trust_policy_permissions = {
    trust_s3 = {
      principals = [{
        type        = "Service"
        identifiers = ["s3.amazonaws.com"]
      }]
    }
  }

  inline_policy_permissions = {
    allow_list_get_replication_conf_from_main = {
      effect    = "Allow"
      actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
      resources = ["arn:aws:s3:::${local.main_bucket_name}"]
    },
    allow_get_object_version_from_main = {
      effect    = "Allow"
      actions   = ["s3:GetObjectVersion", "s3:GetObjectVersionAcl"]
      resources = ["arn:aws:s3:::${local.main_bucket_name}/*"]
    },
    allow_replicate_to_replica = {
      effect    = "Allow"
      actions   = ["s3:ReplicateObject", "s3:ReplicateDelete"]
      resources = ["arn:aws:s3:::${local.replica_bucket_name}/*"]
    }
  }
}
