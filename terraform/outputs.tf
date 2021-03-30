output "BigIp-1" {
  value = aws_cloudformation_stack.same-az.outputs.Bigip1ManagementEipAddress
}
output "BigIp-2" {
  value = aws_cloudformation_stack.same-az.outputs.Bigip2ManagementEipAddress
}

# output BigIp-3 {
#   value = aws_cloudformation_stack.same-az2.outputs.Bigip1ManagementEipAddress
# }
# output BigIp-4 {
#   value = aws_cloudformation_stack.same-az2.outputs.Bigip2ManagementEipAddress
# }
output "Client" {
  value = aws_instance.f5-client-backend-1.public_ip
}
output "Inspection" {
  value = aws_instance.f5-external-backend-1.public_ip
}
output "Workload" {
  value = aws_instance.f5-internal-backend-1.public_ip
}
output "Firewall-1" {
  value = aws_instance.firewall-1.private_ip
}
output "Firewall-2" {
  value = aws_instance.firewall-2.private_ip
}