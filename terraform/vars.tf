variable "aws_region" {
  description = "aws region (default is us-east-1)"
  default     = "us-east-1"
}
variable "az1" {
  description = "zone letter"
  default     = "d"
}
variable "az2" {
  description = "zone letter"
  default     = "a"
}
variable "prefix" {
  description = "unique prefix for tags"
}
variable "ssh_key" {
  description = "name of existing ssh key"
}
variable "trusted_ip" {
  description = "IP address of trusted source for mgmt/testing"
}
variable "licenseKey1" {
  default = ""
}
variable "licenseKey2" {
  default = ""
}
variable "licenseKey3" {
  default = ""
}
variable "licenseKey4" {
  default = ""
}
variable "imageName" {
  default = "Better25Mbps"
}
variable "cft" {
  default = "f5-existing-stack-same-az-cluster-payg-3nic-bigip.template"
}
variable "backendType" {
  default = "t2.micro"
}
variable "bigipType" {
  default = "m5.xlarge"
}
variable "customImageId" {
  default = "OPTIONAL"
}