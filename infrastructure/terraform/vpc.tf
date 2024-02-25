data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

resource "aws_vpc" "workshop" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "workshop"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.workshop.id
  cidr_block              = "10.42.0.0/16"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = "true"

  tags = {
    Name = "workshop-private"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.workshop.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  private_dns_enabled = true
}
