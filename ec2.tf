resource "tls_private_key" "pem_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "SSH-${terraform.workspace}-key"
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

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  vpc_security_group_ids = [ aws_security_group.ec2_sg.id ]

  count = length(module.vpc.public_subnets)
  
  subnet_id = module.vpc.public_subnets[count.index]

  tags = {
    name = "Web-${terraform.workspace}"
  }

}

resource "aws_security_group" "ec2_sg" {
  name        = "EC2-security-group-${terraform.workspace}"
  description = "Allow EC2 access"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}