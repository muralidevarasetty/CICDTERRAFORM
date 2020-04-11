provider "aws" {
  region   = "us-west-2"
}
resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"
assign_generated_ipv6_cidr_block = true
}
resource "aws_subnet" "subnet1" {
  vpc_id = "${aws_vpc.VPC.id}"
  cidr_block = "${cidrsubnet(aws_vpc.VPC.cidr_block, 8, 0)}"
  map_public_ip_on_launch = true
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.VPC.ipv6_cidr_block, 8, 0)}"
  assign_ipv6_address_on_creation = true
  availability_zone = "us-west-2a"
}
resource "aws_subnet" "subnet2" {
  vpc_id = "${aws_vpc.VPC.id}"
  cidr_block = "${cidrsubnet(aws_vpc.VPC.cidr_block, 8, 1)}"
  map_public_ip_on_launch = true
   availability_zone = "us-west-2a"
}
resource "aws_subnet" "subnet3" {
  vpc_id = "${aws_vpc.VPC.id}"
  cidr_block = "${cidrsubnet(aws_vpc.VPC.cidr_block, 8, 2)}"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"
}


resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.VPC.id}"

}

resource "aws_vpn_gateway" "VGW" {
  vpc_id = "${aws_vpc.VPC.id}"

 }

resource "aws_route_table" "CustomRoute1" {
  vpc_id = "${aws_vpc.VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }

}


resource "aws_route_table" "CustomRoute2" {
  vpc_id = "${aws_vpc.VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_vpn_gateway.VGW.id}"
  }
 }



resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.CustomRoute1.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_vpc.VPC.main_route_table_id}"
}

resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.subnet3.id}"
  route_table_id = "${aws_route_table.CustomRoute2.id}"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.VPC.id}"

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "HOST1B" {
  ami         = "ami-087c2c50437d0b80d"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet1.id}"
  private_ip = "${cidrhost(aws_subnet.subnet1.cidr_block,6)}"
  ipv6_addresses = ["${cidrhost(aws_subnet.subnet1.ipv6_cidr_block,291)}"]
  key_name= "ACITKEY"
}

resource "aws_instance" "HOST1A" {
  ami         = "ami-087c2c50437d0b80d"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet1.id}"
  private_ip = "${cidrhost(aws_subnet.subnet1.cidr_block,5)}"
  key_name= "ACITKEY"
}

resource "aws_eip" "EIP" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.HOST1A.id}"
  allocation_id = "${aws_eip.EIP.id}"
}

resource "aws_instance" "HOST2A" {
  ami         = "ami-087c2c50437d0b80d"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet2.id}"
  private_ip = "${cidrhost(aws_subnet.subnet2.cidr_block,5)}"
  key_name= "ACITKEY"
}

resource "aws_instance" "HOST3F" {
  ami         = "ami-087c2c50437d0b80d"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet3.id}"
  private_ip = "${cidrhost(aws_subnet.subnet3.cidr_block,5)}"
  key_name= "ACITKEY"
}

