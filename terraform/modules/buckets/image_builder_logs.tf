module "image_builder_logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"

  bucket = "${var.name}-image-builder-logs"
}
