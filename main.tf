resource "aws_vpc" "rwh_vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true # enable by default

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "rwh_public_subnet" {
  vpc_id                  = aws_vpc.rwh_vpc.id
  cidr_block              = "172.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1"

  tags = {
    Name = "dev-public-subnet"
  }
}

resource "aws_internet_gateway" "rwh_internet_gateway" {
  vpc_id = aws_vpc.rwh_vpc.id

  tags = {
    Name = "dev-internet-gateway"
  }
}

