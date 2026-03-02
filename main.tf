provider "aws"{
    region = var.aws_region
}

resource "aws_vpc" "fitness_vpc"{
    cidr_block          ="10.0.0.0/16"
    enable_dns_hostnames =true
    tags ={
        Name="fitness-vpc"
    }
}
resource "aws_subnet" "public_subnet"{
    vpc_id  = aws_vpc.fitness_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tags ={
        Name = "fitness-public-subnet"
    }
}
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.fitness_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
     Name = "fitness-private-subnet-1"
   }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.fitness_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"
  tags = {
     Name = "fitness-private-subnet-2"
      }
}

resource "aws_internet_gateway" "fitness_igw"{
    vpc_id = aws_vpc.fitness_vpc.id
    tags ={
        Name = "fitness-igw"
    }
}

resource "aws_route_table" "public_rt"{
    vpc_id = aws_vpc.fitness_vpc.id
    route{
          cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.fitness_igw.id
    }
    tags ={
        Name = "fitness-public-rt"
    }
}
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "ec2_sg" {
  name   = "fitness-ec2-sg"
  vpc_id = aws_vpc.fitness_vpc.id
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = { Name = "fitness-ec2-sg" }
}
resource "aws_s3_bucket" "fitness_images_terraform" {
  bucket        = "fitness-app-images-terraform-2026"
  tags = {
    Name = "fitness-images-terraform"
     }
}
resource "aws_s3_bucket_public_access_block" "fitness_images_access" {
  bucket                  = aws_s3_bucket.fitness_images_terraform.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "fitness_images_policy" {
  bucket = aws_s3_bucket.fitness_images_terraform.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.fitness_images_terraform.arn}/*"
    }]
  })
}
resource "aws_s3_bucket" "fitness_thumbnails" {
  bucket        = "fitness-thumbnails-terraform-2026"
  force_destroy = true
  tags = { Name = "fitness-thumbnails" }
}

resource "aws_s3_bucket_public_access_block" "thumbnails_access" {
  bucket                  = aws_s3_bucket.fitness_thumbnails.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "thumbnails_policy" {
  bucket     = aws_s3_bucket.fitness_thumbnails.id
  depends_on = [aws_s3_bucket_public_access_block.thumbnails_access]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.fitness_thumbnails.arn}/*"
    }]
  })
}
resource "aws_iam_role" "lambda_role" {
  name = "fitness-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "thumbnail_generator" {
  function_name = "fitness-thumbnail-generator"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "lambda.zip"

  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.fitness_thumbnails.bucket
    }
  }

  tags = { Name = "fitness-thumbnail-generator" }
}
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
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = { Name = "fitness-db-subnet-group" }
}
resource "aws_db_instance" "fitness_rds" {
  identifier             = "fitness-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.fitness_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  tags = { Name = "fitness-rds" }
}
resource "aws_instance" "fitness_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "fitness-ec2"
  }
}
