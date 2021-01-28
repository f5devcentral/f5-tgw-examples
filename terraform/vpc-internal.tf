resource "aws_vpc" "f5-internal-vpc" {
  cidr_block           = "10.2.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "${var.prefix}-f5-internal-vpc"
  }
}

resource "aws_subnet" "f5-internal-management-1" {
  vpc_id                  = "${aws_vpc.f5-internal-vpc.id}"
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az1}"

  tags = {
    Name = "${var.prefix}-f5-internal-management-1"
  }
}

resource "aws_subnet" "f5-internal-management-2" {
  vpc_id                  = "${aws_vpc.f5-internal-vpc.id}"
  cidr_block              = "10.2.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az2}"

  tags = {
    Name = "${var.prefix}-f5-internal-management-2"
  }
}

resource "aws_subnet" "f5-internal-external-1" {
  vpc_id                  = "${aws_vpc.f5-internal-vpc.id}"
  cidr_block              = "10.2.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az1}"

  tags = {
    Name = "${var.prefix}-f5-internal-external-1"
  }
}

resource "aws_subnet" "f5-internal-external-2" {
  vpc_id                  = "${aws_vpc.f5-internal-vpc.id}"
  cidr_block              = "10.2.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az2}"

  tags = {
    Name = "${var.prefix}-f5-internal-external-2"
  }
}

resource "aws_subnet" "f5-internal-internal-1" {
  vpc_id                  = "${aws_vpc.f5-internal-vpc.id}"
  cidr_block              = "10.2.5.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az1}"

  tags = {
    Name = "${var.prefix}-f5-internal-internal-1"
  }
}

resource "aws_subnet" "f5-internal-internal-2" {
  vpc_id                  = "${aws_vpc.f5-internal-vpc.id}"
  cidr_block              = "10.2.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}${var.az2}"

  tags = {
    Name = "${var.prefix}-f5-internal-internal-2"
  }
}



resource "aws_internet_gateway" "f5-internal-vpc-gw" {
  vpc_id = "${aws_vpc.f5-internal-vpc.id}"

  tags = {
    Name = "${var.prefix}-f5-internal-igw"
  }
}

resource "aws_route_table" "f5-internal-vpc-external-rt" {
  vpc_id = "${aws_vpc.f5-internal-vpc.id}"
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = "${aws_internet_gateway.f5-internal-vpc-gw.id}"
  # }

  tags = {
    Name = "${var.prefix}-f5-internal-external-rt"
  }
}

resource "aws_route" "internal-gateway" {
  route_table_id         = aws_route_table.f5-internal-vpc-external-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.f5-internal-vpc-gw.id}"
  depends_on             = [aws_route_table.f5-internal-vpc-external-rt]
}


resource "aws_route_table_association" "f5-internal-management-1" {
  subnet_id      = aws_subnet.f5-internal-management-1.id
  route_table_id = aws_route_table.f5-internal-vpc-external-rt.id
}

resource "aws_route_table_association" "f5-internal-management-2" {
  subnet_id      = aws_subnet.f5-internal-management-2.id
  route_table_id = aws_route_table.f5-internal-vpc-external-rt.id
}

resource "aws_route_table_association" "f5-internal-external-1" {
  subnet_id      = aws_subnet.f5-internal-external-1.id
  route_table_id = aws_route_table.f5-internal-vpc-external-rt.id
}

resource "aws_route_table_association" "f5-internal-external-2" {
  subnet_id      = aws_subnet.f5-internal-external-2.id
  route_table_id = aws_route_table.f5-internal-vpc-external-rt.id
}



# resource "aws_main_route_table_association" "f5-internal-vpc-association-subnet" {
#   vpc_id         = "${aws_vpc.terraform-vpc.id}"
#   route_table_id = "${aws_route_table.rt1.id}"
# }

resource "aws_security_group" "internal-vpc" {
  name   = "${var.prefix}-f5-internal-vpc"
  vpc_id = "${aws_vpc.f5-internal-vpc.id}"

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