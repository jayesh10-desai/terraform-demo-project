resource "random_password" "db_password" {
  length           = 16
  special         = false
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "mysql-db-password-${terraform.workspace}"
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = random_password.db_password.result
}

resource "aws_security_group" "mysql_sg" {
  name        = "db-security-group-${terraform.workspace}"
  description = "Allow MySQL access"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [ aws_security_group.ec2_sg.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-group-${terraform.workspace}"
  subnet_ids = module.vpc.database_subnets
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage    = 20
  engine              = "mysql"
  engine_version      = "8.0"
  identifier = local.db_name
  instance_class      = var.db_instance_size
  username           = "postgres"
  password           =  aws_secretsmanager_secret_version.db_secret_value.secret_string

  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]

  skip_final_snapshot = true
}
