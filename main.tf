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
}