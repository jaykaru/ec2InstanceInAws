# Create a VPC
resource "aws_vpc" "myvpc" {
    cidr_block           = var.cidr
    # enable_dns_support   = true
    # enable_dns_hostnames = true

    tags = {
        Name = "myvpc"
    }
}

# Create two public subnets
resource "aws_subnet" "sub1" {
    vpc_id                  = aws_vpc.myvpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = true

    tags = {
        Name = "sub1-10.0.1.0/24"-"us-west-2a"
    }
}

resource "aws_subnet" "sub2" {
    vpc_id                  = aws_vpc.myvpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = true

    tags = {
        Name = "sub2-10.0.2.0/24-us-west-2b"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id

    tags = {
        Name = "main-igw"
    }
}

# Create a Route Table
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "public-rt"
    }
}

# Associate the Route Table with the Subnets
resource "aws_route_table_association" "sub1_assoc" {
    subnet_id      = aws_subnet.sub1.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "sub2_assoc" {
    subnet_id      = aws_subnet.sub2.id
    route_table_id = aws_route_table.public_rt.id
}