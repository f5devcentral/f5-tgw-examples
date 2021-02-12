
provider "aws" {
  region = var.aws_region
}

resource "aws_ec2_transit_gateway" "tgw" {
  description = "${var.prefix}-tgw-tf"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc0" {
  subnet_ids         = var.vpc0_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  transit_gateway_default_route_table_association = false
  vpc_id             = var.vpc0
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  subnet_ids         = var.vpc1_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc1
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  subnet_ids         = var.vpc2_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  transit_gateway_default_route_table_association = false  
  vpc_id             = var.vpc2
}

 resource "aws_ec2_transit_gateway_route_table" "client" {
   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
 }

 resource "aws_ec2_transit_gateway_route_table" "workload" {
   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
 }

 resource "aws_ec2_transit_gateway_route" "client_to_workload" {
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.client.id
}

 resource "aws_ec2_transit_gateway_route" "workload_to_client" {
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.client.id
}


resource "aws_ec2_transit_gateway_route_table_propagation" "client_to_peer" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc0.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.client.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "peer_to_client" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.client.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "workload_to_peer" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "peer_to_workload" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload.id
}

 resource "aws_ec2_transit_gateway_route_table_association" "client_to_peer" {
   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc0.id
   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.client.id
 }

 resource "aws_ec2_transit_gateway_route_table_association" "workload_to_peer" {
   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload.id
 }

# resource "aws_ec2_transit_gateway_route_table_association" "peer_to_client" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peer.id
# }


resource "aws_route" "vpc0-external-route" {
  route_table_id            = var.vpc0_external_rt
  destination_cidr_block    = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc1-internal-route" {
  route_table_id            = var.vpc1_internal_rt
  destination_cidr_block    = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc1-internal2-route" {
  route_table_id            = var.vpc1_internal2_rt
  destination_cidr_block    = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc2-external-route" {
  route_table_id            = var.vpc2_external_rt
  destination_cidr_block    = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}