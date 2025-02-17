locals {
  region = terraform.workspace
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.region
}

# provider "aws" {
#   region = "us-west-2"
#   alias = "us-west-2"
# }

terraform {
  backend "s3" {
    bucket = "demo-bucket-london-test-round"
    key    = "terraform"
    region = "eu-west-2"
  } 
}