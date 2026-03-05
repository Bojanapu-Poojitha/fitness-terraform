resource "aws_security_group" "rds_sg" {
  name   = "fitness-rds-sg"
  vpc_id = aws_vpc.fitness_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "fitness-rds-sg" }
}

resource "aws_db_subnet_group" "fitness_db_subnet" {
  name       = "fitness-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = { Name = "fitness-db-subnet-group" }
}

resource "aws_db_instance" "fitness_rds" {
  identifier             = "fitness-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine_version         = "15"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.fitness_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = true
  skip_final_snapshot = true

  tags = { Name = "fitness-rds" }
}