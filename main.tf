locals {
  region = split("_", terraform.workspace)[1]
  db_name = replace("my-mysql-db-${terraform.workspace}", "/(['\\*_])/", "-")
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

terraform {
  backend "s3" {
    bucket = "demo-bucket-london-test-round"
    key    = "terraform"
    region = "eu-west-2"
  } 
}