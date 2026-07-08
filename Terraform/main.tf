terraform {
  required_version = ">=1.0.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}
provider "aws" {
    region = "eu-north-1"
  
}
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_range
  
}
resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.sub_range
    availability_zone = "eu-north-1a"
    map_public_ip_on_launch = true
  
}
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.vpc.id
  
}
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.vpc.id
    route{
        cidr_block = var.route_table_range
        gateway_id = aws_internet_gateway.ig.id
    }
  
}
resource "aws_route_table_association" "rta" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.rt.id
  
}

resource "aws_security_group" "sg" {
    name = "web"
    vpc_id = aws_vpc.vpc.id
    ingress{
        description = "HTTP traffic allow"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "SSH connection"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "app port"
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}
resource "aws_key_pair" "key" {
    key_name = "project_login_key"
    public_key = file(var.login_key)
}
resource "aws_instance" "vm" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.sub1.id
    key_name = aws_key_pair.key.key_name
    vpc_security_group_ids = [aws_security_group.sg.id]
  
}
output "public_ip" {
    value = aws_instance.vm.public_ip 
  
}