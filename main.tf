# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
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
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub1-10.0.1.0/24-eu-west-2a"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub2-10.0.2.0/24-eu-west-2b"
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

# Create a Security Group
resource "aws_security_group" "websg" {
  name        = "websg"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "websg"
  }
}

# Create an S3 Bucket 
resource "aws_s3_bucket" "jkbucket" {
  bucket = "jkbucket-${random_id.suffix.hex}"

  tags = {
    Name = "jkbucket"
  }
}

# Enforce bucket ownership 
resource "aws_s3_bucket_ownership_controls" "jkbucket_ownership" {
  bucket = aws_s3_bucket.jkbucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Allow public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "jkbucket_public_block" {
  bucket = aws_s3_bucket.jkbucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
# Set the bucket ACL to private
resource "aws_s3_bucket_acl" "jkbucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.jkbucket_ownership,
  aws_s3_bucket_public_access_block.jkbucket_public_block]

  bucket = aws_s3_bucket.jkbucket.id
  acl    = "public-read"
}


resource "random_id" "suffix" {
  byte_length = 4
}