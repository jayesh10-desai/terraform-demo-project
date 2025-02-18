module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Web-Instance-VPC-${terraform.workspace}"
  cidr = "10.0.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  database_subnets = [ "10.0.4.0/24", "10.0.5.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  map_public_ip_on_launch = true
  
  single_nat_gateway = true
  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Region = terraform.workspace
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}