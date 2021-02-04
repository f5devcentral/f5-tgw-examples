provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "f5-external-vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "${var.prefix}-f5-external-vpc"
  }
}

resource "aws_subnet" "f5-external-management-1" {
  vpc_id                  = "${aws_vpc.f5-external-vpc.id}"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az1}"

  tags = {
    Name = "${var.prefix}-f5-external-management-1"
  }
}

resource "aws_subnet" "f5-external-management-2" {
  vpc_id                  = "${aws_vpc.f5-external-vpc.id}"
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az2}"

  tags = {
    Name = "${var.prefix}-f5-external-management-2"
  }
}

resource "aws_subnet" "f5-external-external-1" {
  vpc_id                  = "${aws_vpc.f5-external-vpc.id}"
  cidr_block              = "10.1.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az1}"

  tags = {
    Name = "${var.prefix}-f5-external-external-1"
  }
}

resource "aws_subnet" "f5-external-external-2" {
  vpc_id                  = "${aws_vpc.f5-external-vpc.id}"
  cidr_block              = "10.1.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az2}"

  tags = {
    Name = "${var.prefix}-f5-external-external-2"
  }
}

resource "aws_subnet" "f5-external-internal-1" {
  vpc_id                  = "${aws_vpc.f5-external-vpc.id}"
  cidr_block              = "10.1.5.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az1}"

  tags = {
    Name = "${var.prefix}-f5-external-internal-1"
  }
}

resource "aws_subnet" "f5-external-internal-2" {
  vpc_id                  = "${aws_vpc.f5-external-vpc.id}"
  cidr_block              = "10.1.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}${var.az2}"

  tags = {
    Name = "${var.prefix}-f5-external-internal-2"
  }
}

resource "aws_subnet" "f5-external-internal-3" {
  vpc_id                  = "${aws_vpc.f5-external-vpc.id}"
  cidr_block              = "10.1.7.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az1}"

  tags = {
    Name = "${var.prefix}-f5-external-internal-3"
  }
}

resource "aws_subnet" "f5-external-internal-4" {
  vpc_id                  = "${aws_vpc.f5-external-vpc.id}"
  cidr_block              = "10.1.8.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}${var.az2}"

  tags = {
    Name = "${var.prefix}-f5-external-internal-4"
  }
}



resource "aws_internet_gateway" "f5-external-vpc-gw" {
  vpc_id = "${aws_vpc.f5-external-vpc.id}"

  tags = {
    Name = "${var.prefix}-f5-external-igw"
  }
}

resource "aws_route_table" "f5-external-vpc-external-rt" {
  vpc_id = "${aws_vpc.f5-external-vpc.id}"
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = "${aws_internet_gateway.f5-external-vpc-gw.id}"
  # }

  tags = {
    Name = "${var.prefix}-f5-external-external-rt"
  }
}

resource "aws_route" "external-gateway" {
  route_table_id         = aws_route_table.f5-external-vpc-external-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.f5-external-vpc-gw.id}"
  depends_on             = [aws_route_table.f5-external-vpc-external-rt]
}

resource "aws_route_table_association" "f5-external-management-1" {
  subnet_id      = aws_subnet.f5-external-management-1.id
  route_table_id = aws_route_table.f5-external-vpc-external-rt.id
}

resource "aws_route_table_association" "f5-external-management-2" {
  subnet_id      = aws_subnet.f5-external-management-2.id
  route_table_id = aws_route_table.f5-external-vpc-external-rt.id
}

resource "aws_route_table_association" "f5-external-external-1" {
  subnet_id      = aws_subnet.f5-external-external-1.id
  route_table_id = aws_route_table.f5-external-vpc-external-rt.id
}

resource "aws_route_table_association" "f5-external-external-2" {
  subnet_id      = aws_subnet.f5-external-external-2.id
  route_table_id = aws_route_table.f5-external-vpc-external-rt.id
}

resource "aws_route_table" "f5-external-vpc-internal-rt" {
  vpc_id = "${aws_vpc.f5-external-vpc.id}"

  tags = {
    Name = "${var.prefix}-f5-external-internal-rt"
  }
}

resource "aws_route_table_association" "f5-external-internal-1" {
  subnet_id      = aws_subnet.f5-external-internal-1.id
  route_table_id = aws_route_table.f5-external-vpc-internal-rt.id
}

resource "aws_route_table_association" "f5-external-internal-2" {
  subnet_id      = aws_subnet.f5-external-internal-2.id
  route_table_id = aws_route_table.f5-external-vpc-internal-rt.id
}



# resource "aws_main_route_table_association" "f5-external-vpc-association-subnet" {
#   vpc_id         = "${aws_vpc.terraform-vpc.id}"
#   route_table_id = "${aws_route_table.rt1.id}"
# }


resource "aws_security_group" "external-vpc" {
  name   = "${var.prefix}-f5-external-vpc"
  vpc_id = "${aws_vpc.f5-external-vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/14"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.trusted_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}