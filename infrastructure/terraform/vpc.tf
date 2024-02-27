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

resource "aws_network_acl" "workshop" {
  vpc_id = aws_vpc.workshop.id

  egress {
    protocol   = "-1"
    rule_no    = 1
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 2
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

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

resource "aws_security_group" "lambda" {
  name        = "ace135-workshop-chapter2-lambda"
  vpc_id      = aws_vpc.workshop.id

  egress {
    description     = "HTTPS to the private endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.s3_endpoint.id]
  }
}

resource "aws_security_group" "s3_endpoint" {
  name        = "ace135-workshop-chapter2-s3-endpoint"
  vpc_id      = aws_vpc.workshop.id

  ingress {
    description = "HTTPS from the subnet containing the Lambda"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.workshop.cidr_block]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id              = aws_vpc.workshop.id
  service_name        = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.s3_endpoint.id]
  private_dns_enabled = true

  dns_options {
    private_dns_only_for_inbound_resolver_endpoint = false
  }
}
