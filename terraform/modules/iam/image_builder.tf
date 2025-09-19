locals {
  image_builder_name = "${var.name_prefix}-image-builder"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "image_builder" {
  name               = local.image_builder_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "image_builder" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.playbook_bucket}", "arn:aws:s3:::${var.playbook_bucket_replica}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.playbook_bucket}/*", "arn:aws:s3:::${var.playbook_bucket_replica}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.playbook_bucket_logs}/*"]
  }
}

resource "aws_iam_role_policy" "image_builder" {
  name = local.image_builder_name

  role   = aws_iam_role.image_builder.name
  policy = data.aws_iam_policy_document.image_builder.json
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "image_builder" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_instance_profile" "image_builder" {
  name = local.image_builder_name
  role = aws_iam_role.image_builder.name
}
