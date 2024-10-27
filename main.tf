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

resource "aws_route_table" "rwh_public_route_table" {
  vpc_id = aws_vpc.rwh_vpc.id

  tags = {
    Name = "dev-public-route-table"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rwh_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.rwh_internet_gateway.id
}

resource "aws_route_table_association" "rwh_public_rt_assoc" {
  subnet_id      = aws_subnet.rwh_public_subnet.id
  route_table_id = aws_route_table.rwh_public_route_table.id
}

resource "aws_security_group" "rwh_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.rwh_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "rwh_auth" {
  key_name   = "rwhkey"
  public_key = file("~/.ssh/rwhkey.pub")
}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.rwh_auth.id
  vpc_security_group_ids = [aws_security_group.rwh_sg.id]
  subnet_id              = aws_subnet.rwh_public_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }
}