
# ---main/module---- 

locals {
  first_az         = data.aws_availability_zones.available.names[0]
  second_az        = data.aws_availability_zones.available.names[1]
}

###############

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "sdwan1_vpc" {

  cidr_block           = var.sdwan1_vpc_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "sdwan1_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sdwan1_vpc.id

  tags = {
    Name = "${var.name_prefix}sdwan1-gateway"
  }
}

resource "aws_default_route_table" "sdwan1_default_rtb" {
  default_route_table_id = aws_vpc.sdwan1_vpc.default_route_table_id

  route {
    cidr_block = var.ipv4_default
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name_prefix}sdwan1-default-rtb"
  }
}

resource "aws_route_table" "sdwan1_vce-1a_priv_rt" {
  vpc_id = aws_vpc.sdwan1_vpc.id

route {
    cidr_block = var.ipv4_default
    gateway_id = aws_internet_gateway.igw.id
  }

route {
    cidr_block = "46.128.0.0/16"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "sdwan1_vce-1a_priv_rt"
  }
}

#### SUBNETS

resource "aws_subnet" "sdwan1_az1_pub_subnet" {
  vpc_id     = aws_vpc.sdwan1_vpc.id
  cidr_block = var.sdwan1_pub_cidr_block[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "sdwan1_az1_pub_subnet"
  }
}
resource "aws_subnet" "sdwan1_az2_pub_subnet" {
  vpc_id     = aws_vpc.sdwan1_vpc.id
  cidr_block = var.sdwan1_pub_cidr_block[1]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "sdwan1_az2_pub_subnet"
  }
}

resource "aws_subnet" "sdwan1_vce-1a_priv_subnet" {
  vpc_id     = aws_vpc.sdwan1_vpc.id
  cidr_block = var.sdwan1_priv_cidr_block[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "sdwan1_vce-1a_priv_subnet"
  }
}

#### SUBNET TO ROUTE TABLE ASSOCIATIONS

resource "aws_route_table_association" "sdwan1_vce-1a_rt_priv_a" {
  subnet_id         = aws_subnet.sdwan1_vce-1a_priv_subnet.id
  route_table_id    = aws_route_table.sdwan1_vce-1a_priv_rt.id
}


#### SECURITY GROUPS
resource "aws_security_group" "edge_external" {
  name        = "${var.name_prefix}edge-external-sg"
  description = "allow access public edge access"
  vpc_id      = aws_vpc.sdwan1_vpc.id

  ingress {
    description = "allow all vcmp traffic in"
    from_port   = 2426
    to_port     = 2426
    protocol    = "17"
    cidr_blocks = [var.ipv4_default]
  }

  ingress {
    description = "restrict ssh in"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ipv4_default]
  }

  egress {
    description = "allow all traffic out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.ipv4_default]
  }

  tags = {
    Name = "${var.name_prefix}edge-external-sg"
  }
}

resource "aws_security_group" "edge_internal" {
  name        = "${var.name_prefix}edge-internal-sg"
  description = "allow access private edge access"
  vpc_id      = aws_vpc.sdwan1_vpc.id

  ingress {
    description = "allow all internal traffic in"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.ipv4_default]
  }

  egress {
    description = "allow all internal traffic out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.ipv4_default]
  }

  tags = {
    Name = "${var.name_prefix}edge-internal-sg"
  }
}

#### NETWORK INTERFACES
# vce-1A
resource "aws_network_interface" "vce-1a_wan1_eni" {
  subnet_id         = aws_subnet.sdwan1_az1_pub_subnet.id
  security_groups   = ["${aws_security_group.edge_external.id}"]
  source_dest_check = false
  
  depends_on = [
    aws_subnet.sdwan1_az1_pub_subnet
  ]

  tags = {
    Name = "${var.name_prefix}vce-1a-wan1-eni"
  }
}

resource "aws_eip" "vce-1a_wan1_eip" {
  network_interface = aws_network_interface.vce-1a_wan1_eni.id

  depends_on = [
    aws_network_interface.vce-1a_wan1_eni,
    aws_instance.sdwan1_vce_1a
  ]

  tags = {
    Name = "${var.name_prefix}vce-1a-wan1-eip"
  }
}

resource "aws_network_interface" "vce-1a_lan1_eni" {
  subnet_id         = aws_subnet.sdwan1_vce-1a_priv_subnet.id
  security_groups   = ["${aws_security_group.edge_internal.id}"]
  source_dest_check = false
  
  depends_on = [
    aws_subnet.sdwan1_vce-1a_priv_subnet
  ]

  tags = {
    Name = "${var.name_prefix}vce-1a-lan1-eni"
  }
}

### routes

resource "aws_route" "summary_route-vce-1b-to-vce-1a" {
  route_table_id         = aws_route_table.sdwan1_vce-1a_priv_rt.id
  destination_cidr_block = "10.0.0.0/8"   # Replace with the desired destination CIDR
  network_interface_id    = aws_network_interface.vce-1a_lan1_eni.id 
}

#### VELO section

data "velocloud_profile" "aws_edge_profile" {
  name = var.edge_profile
}

data "aws_ami" "velocloud" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["VeloCloud VCE 4.3.1*GA*"]
  }
}

### vce-1A VCO CONFIG
resource "velocloud_edge" "vce-1a" {
  configurationid = data.velocloud_profile.aws_edge_profile.id
  modelnumber     = "virtual"
  name            = "${var.name_prefix}vce-1a"
  site {
    name         = "${var.name_prefix}vce-1a"
    contactname  = "VMware SASE Branch Lab"
    contactemail = "vmware_sase_branch_lab@velocloud.net"
  }
}

#### vce-1A INSTANCE
resource "aws_instance" "sdwan1_vce_1a" {
  ami           = data.aws_ami.velocloud.id
  instance_type = var.ec2_edge_type
  key_name = "${var.aws_secret_key_name}"
  depends_on = [
    velocloud_edge.vce-1a,
    aws_internet_gateway.igw
  ]
 network_interface {
    network_interface_id = aws_network_interface.vce-1a_wan1_eni.id
    device_index         = 0
  }

   network_interface {
    network_interface_id = aws_network_interface.vce-1a_lan1_eni.id
    device_index         = 1

  }
 
  user_data = base64encode(templatefile("${path.module}/templates/vce_userdata.yaml", {
    activation_code = "${velocloud_edge.vce-1a.activationkey}"
    vco_url         = "${var.vco_url}"
  }))

  tags = {
    Name = "${var.name_prefix}vce_1a"
  }
}


#### vce-1B


resource "aws_route_table" "sdwan1_vce-1b_priv_rt" {
  vpc_id = aws_vpc.sdwan1_vpc.id
  tags = {
    "Name" = "sdwan1_vce-1b_priv_rt"
  }
}
resource "aws_subnet" "sdwan1_vce-1b_priv_subnet" {
  vpc_id     = aws_vpc.sdwan1_vpc.id
  cidr_block = var.sdwan1_priv_cidr_block[1]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "sdwan1_vce-1b_priv_subnet"
  }
}

resource "aws_route_table_association" "sdwan1_vce-1b_rt_priv_a" {
  subnet_id         = aws_subnet.sdwan1_vce-1b_priv_subnet.id
  route_table_id    = aws_route_table.sdwan1_vce-1b_priv_rt.id
}

### vce-1B NICs and PUB IP
resource "aws_network_interface" "vce-1b_wan1_eni" {
  subnet_id         = aws_subnet.sdwan1_az2_pub_subnet.id
  security_groups   = ["${aws_security_group.edge_external.id}"]
  source_dest_check = false
  
  depends_on = [
    aws_subnet.sdwan1_az2_pub_subnet
  ]

  tags = {
    Name = "${var.name_prefix}vce-1b-wan1-eni"
  }
}

resource "aws_eip" "vce-1b_wan1_eip" {
  network_interface = aws_network_interface.vce-1b_wan1_eni.id
  
  depends_on = [
    aws_network_interface.vce-1b_wan1_eni,
    aws_instance.sdwan1_vce_1b
    
  ]

  tags = {
    Name = "${var.name_prefix}vce-1b-wan1-eip"
  }
}

resource "aws_network_interface" "vce-1b_lan1_eni" {
  subnet_id         = aws_subnet.sdwan1_vce-1b_priv_subnet.id
  security_groups   = ["${aws_security_group.edge_internal.id}"]
  source_dest_check = false
  
  depends_on = [
    aws_subnet.sdwan1_vce-1b_priv_subnet
  ]

  tags = {
    Name = "${var.name_prefix}vce-1b_lan1-eni"
  }
}

#### vce-1B VCO CONFIG
resource "velocloud_edge" "vce-1b" {
  configurationid = data.velocloud_profile.aws_edge_profile.id
  modelnumber     = "virtual"
  name            = "${var.name_prefix}vce-1b"
  site {
    name         = "${var.name_prefix}vce-1b"
    contactname  = "VMware SASE Branch Lab"
    contactemail = "vmware_sase_branch_lab@velocloud.net"
  }
}

### vce-1B AWS INSTANCE
resource "aws_instance" "sdwan1_vce_1b" {
  ami           = data.aws_ami.velocloud.id
  instance_type = var.ec2_edge_type
  key_name = "${var.aws_secret_key_name}"
  depends_on = [
    velocloud_edge.vce-1b,
    aws_internet_gateway.igw
  ]
  network_interface {
    network_interface_id = aws_network_interface.vce-1b_wan1_eni.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.vce-1b_lan1_eni.id
    device_index         = 1
  }
  
  user_data = base64encode(templatefile("${path.module}/templates/vce_userdata.yaml", {
    activation_code = "${velocloud_edge.vce-1b.activationkey}"
    vco_url         = "${var.vco_url}"
  }))

  tags = {
    Name = "${var.name_prefix}vce_1b"
  }
}