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

