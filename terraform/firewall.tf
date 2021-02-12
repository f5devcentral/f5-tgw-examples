data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true
  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_network_interface" "fw-1-ext" {
  subnet_id              = aws_subnet.f5-external-external-1.id
  security_groups = [aws_security_group.external-vpc.id]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-firewall-1-ext"
  }
}

resource "aws_network_interface" "fw-1-int" {
  subnet_id              = aws_subnet.f5-external-internal-1.id
  security_groups = [aws_security_group.external-vpc.id]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-firewall-1-int"
  }
}


resource "aws_instance" "firewall-1" {
  ami                    = data.aws_ami.centos.id
  instance_type          = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.fw-1-ext.id
    device_index         = 0
  }
  

  network_interface {
    network_interface_id = aws_network_interface.fw-1-int.id
    device_index         = 1
  }

  key_name               = var.ssh_key
  tags = {
    Name = "${var.prefix}-firewall-1"
  }
}

# fw 2

resource "aws_network_interface" "fw-2-ext" {
  subnet_id              = aws_subnet.f5-external-external-1.id
  security_groups = [aws_security_group.external-vpc.id]
  source_dest_check = false  
  tags = {
    Name = "${var.prefix}-firewall-2-ext"
  }
}

resource "aws_network_interface" "fw-2-int" {
  subnet_id              = aws_subnet.f5-external-internal-1.id
  security_groups = [aws_security_group.external-vpc.id]
  source_dest_check = false  
  tags = {
    Name = "${var.prefix}-firewall-2-int"
  }
}


resource "aws_instance" "firewall-2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.fw-2-ext.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fw-2-int.id
    device_index         = 1
  }
  
  key_name               = var.ssh_key
  user_data              = <<-EOF
#cloud-config
write_files:
- content: |
    network:
      version: 2
      renderer: networkd
      ethernets:
        eth1:
          dhcp4: yes
          dhcp6: no
  owner: root:root
  path: /etc/netplan/51-eth1.yaml
  permissions: '0644'
runcmd:
  - echo 1 > /proc/sys/net/ipv4/ip_forward
  - netplan apply  
              EOF
  tags = {
    Name = "${var.prefix}-firewall-2"
  }
}


