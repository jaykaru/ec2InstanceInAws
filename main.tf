resource "aws_vpc" "main" {
    cidr_block           = var.cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "main-vpc"
    }
}

resource "aws_subnet" "sub1" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = true

    tags = {
        Name = "sub1"
    }
}

resource "aws_subnet" "sub2" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = true

    tags = {
        Name = "sub2"
    }
}