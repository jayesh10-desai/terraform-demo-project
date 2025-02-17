resource "random_password" "db_password" {
  length           = 16
  special         = false
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "mysql-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = random_password.db_password.result
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql-security-group"
  description = "Allow MySQL access"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "my-db-subnet-group"
  subnet_ids = module.vpc.database_subnets
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage    = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = var.db_instance_size
  identifier         = "my-mysql-db-${terraform.workspace}"
  username           = "postgres"
  password           =  aws_secretsmanager_secret_version.db_secret_value.secret_string

  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]

  skip_final_snapshot = true
}
