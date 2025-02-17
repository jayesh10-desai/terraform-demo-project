module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "default-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${terraform.workspace}a", "${terraform.workspace}b"]
  database_subnets = [ "10.0.4.0/24", "10.0.5.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  single_nat_gateway = true
  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Region = terraform.workspace
  }
}