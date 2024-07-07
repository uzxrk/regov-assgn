provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_app_instance" {
  ami           = "ami-01f6c796d6dbc1e36" #ubuntu
  instance_type = "t3.large"

  vpc_security_group_ids = [aws_security_group.my_app_sg.id]

  tags = {
    Name = "ProdAppInstance"
  }
}

resource "aws_security_group" "my_app_sg" {
  name_prefix = "prod_app_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

output "my_app_instance_ip" {
  value = aws_instance.my_app_instance.public_ip
}
