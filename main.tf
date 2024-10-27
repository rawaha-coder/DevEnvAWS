resource "aws_vpc" "rwh_vpc" {
    cidr_block = "1072.31.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true # enable by default

    tags = {
      Name = "dev"
    }
}