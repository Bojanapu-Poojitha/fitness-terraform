provider "aws"{
    region = var.aws_region
}

resource "aws_vpc" "fitness_vpc"{
    cidr_block          ="10.0.0.0/16"
    enable_dns_hostname =true
    tags ={
        Name="fitness-vpc"
    }
}