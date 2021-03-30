
provider "aws" {
  region = var.aws_region
}

resource "aws_ec2_transit_gateway" "tgw" {
  description = "${var.prefix}-tgw-tf"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc0" {
  subnet_ids                                      = var.vpc0_subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  transit_gateway_default_route_table_association = false
  vpc_id                                          = var.vpc0
  tags = {
    Name = "${var.prefix}-client-vpc"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  subnet_ids         = var.vpc1_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc1
  tags = {
    Name = "${var.prefix}-external-vpc"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  subnet_ids                                      = var.vpc2_subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  transit_gateway_default_route_table_association = false
  vpc_id                                          = var.vpc2
  tags = {
    Name = "${var.prefix}-internal-vpc"
  }
}



resource "aws_ec2_transit_gateway_route_table" "client" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.prefix}-client-vpc"
  }  
}

resource "aws_ec2_transit_gateway_route_table" "workload" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "${var.prefix}-internal-vpc"
  }  
}

resource "aws_ec2_transit_gateway_route_table_association" "client_to_peer" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc0.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.client.id
}

resource "aws_ec2_transit_gateway_route_table_association" "workload_to_peer" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload.id
}



resource "aws_route" "vpc0-external-route" {
  route_table_id         = var.vpc0_external_rt
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc1-internal2-route" {
  route_table_id         = var.vpc1_internal2_rt
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc2-external-route" {
  route_table_id         = var.vpc2_external_rt
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc1-internal2-route-tgw" {
  route_table_id         = var.vpc1_internal2_rt
  destination_cidr_block = "192.0.2.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
