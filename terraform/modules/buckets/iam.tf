data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "replication" {
  name               = "${var.name}-bucket-replication-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.main_bucket_name}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObjectVersion", "s3:GetObjectVersionAcl"]
    resources = ["arn:aws:s3:::${local.main_bucket_name}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ReplicateObject", "s3:ReplicateDelete"]
    resources = ["arn:aws:s3:::${local.replica_bucket_name}/*"]
  }
}

resource "aws_iam_role_policy" "replication" {
  name = "${var.name}-bucket-replication-policy"

  role   = aws_iam_role.replication.id
  policy = data.aws_iam_policy_document.replication.json
}
