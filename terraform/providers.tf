locals {
  default_tags = {
    Application = var.app_name
    Environment = var.environment
    Department  = "Technology"
    Terraform   = "True"
  }
}

provider "aws" {
  region = var.region.main
  alias  = "main"

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = var.region.failover
  alias  = "failover"

  default_tags {
    tags = merge(local.default_tags, {
      IsFailover = "True"
    })
  }
}
