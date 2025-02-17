resource "tls_private_key" "pem_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.pem_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "secretmasterDB" {
   name = "${terraform.workspace}-instance-pem"
}

resource "aws_secretsmanager_secret_version" "pem_version" {
  secret_id = aws_secretsmanager_secret.secretmasterDB.id
  secret_string = tls_private_key.pem_key.private_key_pem
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.deployer.key_name

  count = length(module.vpc.private_subnets)
  
  subnet_id = module.vpc.private_subnets[count.index]

}