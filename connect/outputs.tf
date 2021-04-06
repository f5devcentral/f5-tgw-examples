output "Tmsh" {
  value = <<-EOF
  # setup TGW connect
aws ec2 create-tags --resources ${aws_ec2_transit_gateway.tgw.id} --region ${var.aws_region} --tags Key=Name,Value=${var.prefix}-tgw
aws ec2 modify-transit-gateway --options '{"AddTransitGatewayCidrBlocks":["10.254.254.0/24"]}' --transit-gateway-id ${aws_ec2_transit_gateway.tgw.id} --region ${var.aws_region}
aws ec2 create-transit-gateway-connect --transport-transit-gateway-attachment-id ${aws_ec2_transit_gateway_vpc_attachment.vpc1.id} --region ${var.aws_region} --options '{"Protocol":"gre"}'  --tag-specifications 'ResourceType=transit-gateway-attachment,Tags=[{Key=Name,Value=${var.prefix}-connect}]'
export TGW_ATTACH_ID=$(aws ec2 describe-transit-gateway-connects --filters "Name=tag:Name,Values=${var.prefix}-connect" --query "TransitGatewayConnects[].TransitGatewayAttachmentId|[0]" --region ${var.aws_region}|sed  s/\"//g) 
aws ec2   create-transit-gateway-connect-peer --transit-gateway-attachment-id $TGW_ATTACH_ID --peer-address ${var.bigip1_self} --bgp-options PeerAsn=65520 --inside-cidr-blocks 169.254.10.0/29 --region ${var.aws_region} --transit-gateway-address 10.254.254.11
aws ec2   create-transit-gateway-connect-peer --transit-gateway-attachment-id $TGW_ATTACH_ID --peer-address ${var.bigip2_self} --bgp-options PeerAsn=65520 --inside-cidr-blocks 169.254.20.0/29 --region ${var.aws_region} --transit-gateway-address 10.254.254.12
aws ec2   create-transit-gateway-connect-peer --transit-gateway-attachment-id $TGW_ATTACH_ID --peer-address ${var.bigip3_self} --bgp-options PeerAsn=65520 --inside-cidr-blocks 169.254.30.0/29 --region ${var.aws_region} --transit-gateway-address 10.254.254.13
aws ec2   create-transit-gateway-connect-peer --transit-gateway-attachment-id $TGW_ATTACH_ID --peer-address ${var.bigip4_self} --bgp-options PeerAsn=65520 --inside-cidr-blocks 169.254.40.0/29 --region ${var.aws_region} --transit-gateway-address 10.254.254.14  

# run the following TMSH commands on the BIG-IP device #1
modify /net self internal-self allow-service all
modify /net vlan internal mtu 9001
modify sys db config.allow.rfc3927 { value "enable" }
modify sys db connection.vlankeyed value disable
create /net route tgw network 10.0.0.0/8 gw 10.1.7.1
create /net route tgw_connect network 10.254.254.0/24 gw 10.1.7.1
create /net tunnels tunnel tgw-connect remote-address 10.254.254.11 traffic-group traffic-group-local-only profile gre local-address ${var.bigip1_self} mtu 8901
create /net self bgp address 169.254.10.1/29 vlan tgw-connect allow-service all
modify /net route-domain 0 routing-protocol replace-all-with { BGP }
create /ltm profile fastl4 my_route_friendly_fastl4 defaults-from fastL4 idle-timeout 300 loose-close enabled loose-initialization enabled reset-on-timeout disabled syn-cookie-enable disabled

create /ltm virtual-address 10.0.0.0 address 10.0.0.0 mask 255.255.0.0  route-advertisement selective traffic-group none
create /ltm virtual fwd_ten_zero_vs destination 10.0.0.0:0 ip-forward ip-protocol any profiles replace-all-with { my_route_friendly_fastl4 } mask 255.255.0.0

create /ltm virtual-address 10.1.0.0 address 10.1.0.0 mask 255.255.0.0  route-advertisement selective traffic-group none
create /ltm virtual fwd_ten_one_vs destination 10.1.0.0:0 ip-forward ip-protocol any profiles replace-all-with { my_route_friendly_fastl4 } mask 255.255.0.0

#create /ltm virtual-address 10.2.0.0 address 10.2.0.0 mask 255.255.0.0  route-advertisement selective traffic-group traffic-group-1
create /ltm virtual-address 10.2.0.0 address 10.2.0.0 mask 255.255.0.0  route-advertisement selective traffic-group none
create /ltm virtual fwd_ten_two_vs destination 10.2.0.0:0 ip-forward ip-protocol any profiles replace-all-with { my_route_friendly_fastl4 } mask 255.255.0.0
# run the following TMSH commands on the BIG-IP device #1
modify /net self internal-self allow-service all
modify /net vlan internal mtu 9001
modify sys db config.allow.rfc3927 { value "enable" }
modify sys db connection.vlankeyed value disable
create /net tunnels tunnel tgw-connect remote-address 10.254.254.12 traffic-group traffic-group-local-only profile gre local-address ${var.bigip2_self}  mtu 8901
create /net self bgp address 169.254.20.1/29 vlan tgw-connect allow-service all
modify /net route-domain 0 routing-protocol replace-all-with { BGP }


#
# 3,4: optional, uncomment to use
#
  # run the following TMSH commands on the BIG-IP device #3
  
modify /net self internal-self allow-service all
modify sys db config.allow.rfc3927 { value "enable" }
modify sys db connection.vlankeyed value disable
create /net route tgw network 10.0.0.0/8 gw 10.1.7.1
create /net route tgw_connect network 10.254.254.0/24 gw 10.1.7.1
create /net tunnels tunnel tgw-connect remote-address 10.254.254.13 traffic-group traffic-group-local-only profile gre local-address ${var.bigip3_self} mtu 8901
create /net self bgp address 169.254.30.1/29 vlan tgw-connect allow-service all
modify /net route-domain 0 routing-protocol replace-all-with { BGP }
create /ltm profile fastl4 my_route_friendly_fastl4 defaults-from fastL4 idle-timeout 300 loose-close enabled loose-initialization enabled reset-on-timeout disabled syn-cookie-enable disabled

create /ltm virtual-address 10.0.0.0 address 10.0.0.0 mask 255.255.0.0  route-advertisement selective traffic-group none
create /ltm virtual fwd_ten_zero_vs destination 10.0.0.0:0 ip-forward ip-protocol any profiles replace-all-with { my_route_friendly_fastl4 } mask 255.255.0.0

create /ltm virtual-address 10.1.0.0 address 10.1.0.0 mask 255.255.0.0  route-advertisement selective traffic-group none
create /ltm virtual fwd_ten_one_vs destination 10.1.0.0:0 ip-forward ip-protocol any profiles replace-all-with { my_route_friendly_fastl4 } mask 255.255.0.0

#create /ltm virtual-address 10.2.0.0 address 10.2.0.0 mask 255.255.0.0  route-advertisement selective traffic-group traffic-group-1
create /ltm virtual-address 10.2.0.0 address 10.2.0.0 mask 255.255.0.0  route-advertisement selective traffic-group none
create /ltm virtual fwd_ten_two_vs destination 10.2.0.0:0 ip-forward ip-protocol any profiles replace-all-with { my_route_friendly_fastl4 } mask 255.255.0.0

# run the following TMSH commands on the BIG-IP device #4

modify /net self internal-self allow-service all
modify sys db config.allow.rfc3927 { value "enable" }
modify sys db connection.vlankeyed value disable
create /net tunnels tunnel tgw-connect remote-address 10.254.254.14 traffic-group traffic-group-local-only profile gre local-address ${var.bigip4_self} mtu 8901
create /net self bgp address 169.254.40.1/29 vlan tgw-connect allow-service all
modify /net route-domain 0 routing-protocol replace-all-with { BGP }


EOF
}