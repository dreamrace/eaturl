terraform {

}

provider "aws" {
  version    = "~> 2.8"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_availability_zones" "current" {
}

locals {
  selected_availability_zones = slice(data.aws_availability_zones.current.names, 0, var.number_of_zone)
}

resource "aws_default_vpc" "default" {
}

data "aws_subnet_ids" "target" {
  vpc_id = aws_default_vpc.default.id
}

resource "aws_security_group" "allow_localaccess" {
  vpc_id      = aws_default_vpc.default.id
  name        = "allow_local"
  description = "Allow Local inbound traffic"

  ingress {
    description = "Traffic from local"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["118.140.157.66/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id


  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/////////////////////////////////////////////////////////////////////////

data "aws_route53_zone" "target" {
  name = var.host_zone
}
