provider "aws" {
  region = "us-east-1"
  alias  = "use1"

  default_tags {
    tags = {
      Terraform   = "True"
      Environment = var.environment
    }
  }
}

provider "aws" {
  region = "us-west-1"
  alias  = "usw1"

  default_tags {
    tags = {
      Terraform   = "True"
      Environment = var.environment
    }
  }
}
