provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_app_instance" {
  ami           = "ami-01f6c796d6dbc1e36" #ubuntu
  instance_type = "t2.micro"

  tags = {
    Name = "UATAppInstance"
  }
}

output "my_app_instance_ip" {
  value = aws_instance.my_app_instance.public_ip
}
