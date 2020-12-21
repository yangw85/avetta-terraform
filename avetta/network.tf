# VPC
resource "aws_vpc" "prod-vpc" {
    cidr_block = "172.16.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    instance_tenancy = "default"

    tags = {
        Name = "prod-vpc"
    }
}

#Subnets
resource "aws_subnet" "prod-subnet-public-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "172.16.1.0/24"
    map_public_ip_on_launch = "true"
    tags = {
        Name = "prod-subnet-public-1"
    }
}

resource "aws_subnet" "prod-subnet-private-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "172.16.2.0/24"
    map_public_ip_on_launch = "false"
    tags = {
        Name = "prod-subnet-private-1"
    }
}

#Network Routing
resource "aws_internet_gateway" "prod-igw" {
    vpc_id = aws_vpc.prod-vpc.id
    tags = {
        Name = "prod-igw"
    }
}

resource "aws_route_table" "prod-public-crt" {
    vpc_id = aws_vpc.prod-vpc.id

    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.prod-igw.id
    }

    tags = {
        Name = "prod-public-crt"
    }
}

resource "aws_route_table_association" "prod-crta-public-subnet-1"{
    subnet_id = aws_subnet.prod-subnet-public-1.id
    route_table_id = aws_route_table.prod-public-crt.id
}

#Security Groups
resource "aws_security_group" "instance" {
  name = "prod-instance"
  vpc_id = aws_vpc.prod-vpc.id

  ingress {
    from_port   = var.SERVER_PORT
    to_port     = var.SERVER_PORT
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb" {
  name = "prod-elb"
  vpc_id = aws_vpc.prod-vpc.id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
