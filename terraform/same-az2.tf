
resource "aws_cloudformation_stack" "same-az2" {
  name         = "${var.prefix}-same-az2-stack"
  capabilities = ["CAPABILITY_IAM"]
  parameters = {
    Vpc                     = aws_vpc.f5-external-vpc.id
    allowUsageAnalytics     = "No"
    application             = "f5app"
    bigIpModules            = "ltm:nominal"
    costcenter              = "f5costcenter"
    customImageId           = var.customImageId
    declarationUrl          = "none"
    environment             = "f5env"
    group                   = "f5group"
    imageName               = var.imageName
    instanceType            = var.bigipType
    managementSubnetAz1     = aws_subnet.f5-external-management-2.id
    ntpServer               = "0.pool.ntp.org"
    owner                   = "f5owner"
    provisionPublicIP       = "Yes"
    restrictedSrcAddress    = var.trusted_ip
    restrictedSrcAddressApp = var.trusted_ip
    sshKey                  = var.ssh_key
    subnet1Az1              = aws_subnet.f5-external-external-2.id
    subnet2Az1              = aws_subnet.f5-external-internal-4.id
    timezone                = "UTC"
    licenseKey1             = var.licenseKey3
    licenseKey2             = var.licenseKey4
  }
  template_url = "https://${aws_s3_bucket.tf_s3_bucket.bucket_domain_name}/f5-existing-stack-same-az-cluster-payg-3nic-bigip.template"
  depends_on   = [aws_s3_bucket_object.custom_cft]
}

