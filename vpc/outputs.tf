output Tmsh {
  value = <<-EOF
  # run the following TMSH commands on the BIG-IP device
create /net self external-float address ${var.bigip_float}/24 traffic-group traffic-group-1 allow-service none vlan external
create /ltm pool tgw_pool members replace-all-with { 10.1.7.1:0 }
create /ltm poo fw_pool members replace-all-with { ${var.fw_ips} }
create /ltm virtual to_fw_vs destination 10.0.0.0:0 ip-protocol any pool fw_pool translate-address disabled translate-port disabled mask 255.0.0.0  profiles replace-all-with  { fastL4 } vlans replace-all-with { internal } vlans-enabled
create /ltm virtual to_tgw_vs destination 10.0.0.0:0 ip-protocol any pool tgw_pool translate-address disabled translate-port disabled mask 255.0.0.0  profiles replace-all-with  { fastL4 } vlans replace-all-with { external } vlans-enabled
EOF
}