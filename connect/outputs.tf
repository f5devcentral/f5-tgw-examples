output "Tmsh" {
  value = <<-EOF
  # setup TGW connect
  aws ec2 create-tags --resources ${aws_ec2_transit_gateway.tgw.id} --region ${var.aws_region} --tags Key=Name,Value=${var.prefix}-tgw
  aws ec2 modify-transit-gateway --options '{"AddTransitGatewayCidrBlocks":["192.0.2.0/24"]}' --transit-gateway-id ${aws_ec2_transit_gateway.tgw.id} --region ${var.aws_region}
  aws ec2 create-transit-gateway-connect --transport-transit-gateway-attachment-id ${aws_ec2_transit_gateway_vpc_attachment.vpc1.id} --region ${var.aws_region} --options '{"Protocol":"gre"}'  --tag-specifications 'ResourceType=transit-gateway-attachment,Tags=[{Key=Name,Value=${var.prefix}-connect}]'
  export TGW_ATTACH_ID=$(aws ec2 describe-transit-gateway-connects --filters "Name=tag:Name,Values=${var.prefix}-connect" --query "TransitGatewayConnects[].TransitGatewayAttachmentId|[0]" --region ${var.aws_region}|sed  s/\"//g) 
  aws ec2   create-transit-gateway-connect-peer --transit-gateway-attachment-id $TGW_ATTACH_ID --peer-address ${var.bigip1_self} --bgp-options PeerAsn=65520 --inside-cidr-blocks 169.254.10.0/29 --region ${var.aws_region} --transit-gateway-address 192.0.2.11
  aws ec2   create-transit-gateway-connect-peer --transit-gateway-attachment-id $TGW_ATTACH_ID --peer-address ${var.bigip2_self} --bgp-options PeerAsn=65520 --inside-cidr-blocks 169.254.20.0/29 --region ${var.aws_region} --transit-gateway-address 192.0.2.12
  # run the following TMSH commands on the BIG-IP device
  modify /net self internal-self allow-service all
  modify sys db config.allow.rfc3927 { value "enable" }
create /net route tgw network 192.0.2.0/24 gw 10.1.7.1
create /net tunnels tunnel tgw-connect remote-address 192.0.2.10 traffic-group traffic-group-local-only profile gre local-address ${var.bigip1_self}
create /net self bgp address 169.254.10.1/29 vlan tgw-connect allow-service all
modify /net route-domain 0 routing-protocol replace-all-with { BGP }
create /ltm virtual-address 10.0.0.0 address 10.0.0.0 mask 255.255.0.0  route-advertisement selective traffic-group none
create /ltm virtual fwd_ten_zero_vs destination 10.0.0.0:0 ip-forward ip-protocol any profiles replace-all-with { fastL4 } mask 255.255.0.0
create /ltm virtual to_fw_vs destination 10.0.0.0:0 ip-protocol any pool fw_pool translate-address disabled translate-port disabled mask 255.0.0.0  profiles replace-all-with  { fastL4 } vlans replace-all-with { internal } vlans-enabled
create /ltm virtual to_tgw_vs destination 10.0.0.0:0 ip-protocol any pool tgw_pool translate-address disabled translate-port disabled mask 255.0.0.0  profiles replace-all-with  { fastL4 } vlans replace-all-with { external } vlans-enabled
EOF
}