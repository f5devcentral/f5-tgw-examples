resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket_prefix = "${var.prefix}-cross-az-tf-s3bucket"
}
resource "aws_s3_bucket_object" "custom_cft" {
  bucket = "${aws_s3_bucket.tf_s3_bucket.id}"
  key = "f5-existing-stack-same-az-cluster-payg-3nic-bigip.template"
  source = "f5-existing-stack-same-az-cluster-payg-3nic-bigip.template"
}
resource "aws_cloudformation_stack" "same-az"  {
  name = "${var.prefix}-same-az-external-stack"
  capabilities = ["CAPABILITY_IAM"]
  parameters = { 
	Vpc = aws_vpc.f5-external-vpc.id
        allowUsageAnalytics = "No"
	application = "f5app"
	bigIpModules = "ltm:nominal,apm:nominal"
	costcenter = "f5costcenter"
	customImageId = "OPTIONAL"
	declarationUrl = "none"
	environment = "f5env"
	group = "f5group"
	imageName = "Best1000Mbps"
	instanceType = "m5.xlarge"
	managementSubnetAz1 = aws_subnet.f5-external-management-1.id
#	managementSubnetAz2 = aws_subnet.f5-external-management-1.id
	ntpServer = "0.pool.ntp.org"
	owner = "f5owner"
	provisionPublicIP = "Yes"
	restrictedSrcAddress = var.trusted_ip
	restrictedSrcAddressApp = var.trusted_ip
	sshKey = "${var.ssh_key}"
	subnet1Az1 = aws_subnet.f5-external-external-1.id
#	subnet1Az2 = aws_subnet.f5-external-external-1.id
	subnet2Az1 = aws_subnet.f5-external-internal-1.id
#	subnet2Az2= aws_subnet.f5-external-internal-1.id
	timezone = "UTC"
	}
#  template_url = "https://f5-cft.s3.amazonaws.com/f5-existing-stack-across-az-cluster-payg-3nic-bigip.template"
  template_url = "https://${aws_s3_bucket.tf_s3_bucket.bucket_domain_name}/f5-existing-stack-same-az-cluster-payg-3nic-bigip.template"
#  template_body = file("${path.module}/f5-existing-stack-across-az-cluster-payg-3nic-bigip.template")
}

# resource "aws_route" "internal_bigip_route" {
#   route_table_id         = aws_route_table.f5-external-vpc-internal-rt.id
#   destination_cidr_block = "10.0.0.0/16"
#   network_interface_id = aws_cloudformation_stack.same-az.outputs.Bigip1subnet1Az1Interface
# }

 # resource "aws_route" "internal_bigip_route2" {
 #   route_table_id         = aws_route_table.f5-external-vpc-internal-rt.id
 #   destination_cidr_block = "10.2.0.0/16"
 #   network_interface_id = aws_cloudformation_stack.same-az.outputs.Bigip1subnet1Az1Interface
 # }

 # resource "aws_route" "external_bigip_route" {
 #   route_table_id         = aws_route_table.f5-external-vpc-external-rt.id
 #   destination_cidr_block = "10.0.0.0/16"
 #   network_interface_id = aws_cloudformation_stack.same-az.outputs.Bigip1subnet1Az1Interface
 # }
