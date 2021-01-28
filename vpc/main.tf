
provider "aws" {
  region = var.aws_region
}

resource "aws_ec2_transit_gateway" "tgw" {
  description = "${var.prefix}-tgw-tf"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  subnet_ids         = var.vpc1_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc1
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  subnet_ids         = var.vpc2_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc2
}

resource "aws_route" "vpc1-external-route" {
  route_table_id            = var.vpc1_external_rt
  destination_cidr_block    = "10.2.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc2-external-route" {
  route_table_id            = var.vpc2_external_rt
  destination_cidr_block    = "10.1.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}