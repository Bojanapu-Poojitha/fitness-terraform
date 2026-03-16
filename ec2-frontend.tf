resource "aws_security_group" "fitness_frontend_sg" {
  name   = "fitness-frontend-sg"
  vpc_id = aws_vpc.fitness_vpc.id

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

  tags = { Name = "fitness-frontend-sg" }
}

resource "aws_instance" "fitness_frontend_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
   subnet_id              = aws_subnet.public_subnet.id   
  vpc_security_group_ids = [aws_security_group.fitness_frontend_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "fitness-frontend-ec2"
  }
}

resource "aws_eip" "frontend_eip" {
  instance = aws_instance.fitness_frontend_ec2.id
  domain   = "vpc"

  tags = {
    Name = "fitness-frontend-eip"
  }
}
