terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.0.1"
    }
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_instance" "web" {
  ami           = "ami-0eb260c4d5475b901"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}