
resource "aws_vpc" "f5-client-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "${var.prefix}-f5-client-vpc"
  }
}

resource "aws_subnet" "f5-client-management-1" {
  vpc_id                  = aws_vpc.f5-client-vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az1}"

  tags = {
    Name = "${var.prefix}-f5-client-management-1"
  }
}

resource "aws_subnet" "f5-client-management-2" {
  vpc_id                  = aws_vpc.f5-client-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}${var.az2}"

  tags = {
    Name = "${var.prefix}-f5-client-management-2"
  }
}




resource "aws_internet_gateway" "f5-client-vpc-gw" {
  vpc_id = aws_vpc.f5-client-vpc.id

  tags = {
    Name = "${var.prefix}-f5-client-igw"
  }
}

resource "aws_route_table" "f5-client-vpc-external-rt" {
  vpc_id = aws_vpc.f5-client-vpc.id
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = "${aws_internet_gateway.f5-client-vpc-gw.id}"
  # }

  tags = {
    Name = "${var.prefix}-f5-client-external-rt"
  }
}

resource "aws_route" "client-gateway" {
  route_table_id         = aws_route_table.f5-client-vpc-external-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.f5-client-vpc-gw.id
  depends_on             = [aws_route_table.f5-client-vpc-external-rt]
}

resource "aws_route_table_association" "f5-client-management-1" {
  subnet_id      = aws_subnet.f5-client-management-1.id
  route_table_id = aws_route_table.f5-client-vpc-external-rt.id
}

resource "aws_route_table_association" "f5-client-management-2" {
  subnet_id      = aws_subnet.f5-client-management-2.id
  route_table_id = aws_route_table.f5-client-vpc-external-rt.id
}


# resource "aws_main_route_table_association" "f5-external-vpc-association-subnet" {
#   vpc_id         = "${aws_vpc.terraform-vpc.id}"
#   route_table_id = "${aws_route_table.rt1.id}"
# }


resource "aws_security_group" "client-vpc" {
  name   = "${var.prefix}-f5-client-vpc"
  vpc_id = aws_vpc.f5-client-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
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