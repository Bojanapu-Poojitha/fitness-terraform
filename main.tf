provider "aws"{
    region = var.aws_region
}

resource "aws_vpc" "fitness_vpc"{
    cidr_block          ="10.0.0.0/16"
    enable_dns_hostname =true
    tags ={
        Name="fitness-vpc"
    }

resource "aws_subnet" "public_subnet"{
    vpc_id  = aws_vpc.fitness_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tage ={
        Name = "fitness-public-subnet"
    }
}
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.fitness_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"
  tags =
   {
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
}

}