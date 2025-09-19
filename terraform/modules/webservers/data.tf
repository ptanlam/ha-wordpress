data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "this" {
  most_recent = true

  owners = ["self"]

  filter {
    name   = "tag:Ec2ImageBuilderArn"
    values = ["arn:aws:imagebuilder:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:image/${var.name}*"]
  }
}
