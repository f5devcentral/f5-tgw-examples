data "template_file" "vpc_tfvars" {
  template = "${file("../vpc/terraform.tfvars.example")}"
  vars = {
    prefix           = var.prefix
    aws_region       = var.aws_region
    vpc0	     = aws_vpc.f5-client-vpc.id
    vpc0_subnet_ids  = "[\"${aws_subnet.f5-client-management-1.id}\",\"${aws_subnet.f5-client-management-2.id}\"]"
    vpc1             = aws_vpc.f5-external-vpc.id
    vpc1_subnet_ids  = "[\"${aws_subnet.f5-external-internal-1.id}\",\"${aws_subnet.f5-external-internal-2.id}\"]"
    vpc2             = aws_vpc.f5-internal-vpc.id
    vpc2_subnet_ids  = "[\"${aws_subnet.f5-internal-internal-1.id}\",\"${aws_subnet.f5-internal-internal-2.id}\"]"
    vpc0_external_rt = aws_route_table.f5-client-vpc-external-rt.id    
    vpc1_external_rt = aws_route_table.f5-external-vpc-external-rt.id
    vpc2_external_rt = aws_route_table.f5-internal-vpc-external-rt.id
    vpc1_internal_rt = aws_route_table.f5-external-vpc-internal-rt.id
  }
}
resource "local_file" "vpc_tfvars" {
  content  = "${data.template_file.vpc_tfvars.rendered}"
  filename = "../vpc/terraform.tfvars"
}