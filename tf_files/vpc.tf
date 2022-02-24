# VPC to hold my resources
resource "aws_vpc" "xe-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"

    tags = {
        Name = "${lookup(var.project_name, var.env)}-vpc"
    }
}

# public subnet for the eu-central-1a subnet on the VPC
resource "aws_subnet" "xe-subnet-public" {
    vpc_id = "${aws_vpc.xe-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-central-1a"

    tags = {
        Name = "${lookup(var.project_name, var.env)}-public-subnet"
    }
}

# Create VPC Endpoint for SQS 
resource "aws_vpc_endpoint" "sqs" {
    vpc_id = "${aws_vpc.xe-vpc.id}"
    service_name = "com.amazonaws.${var.aws_region}.sqs"
    security_group_ids = ["${aws_security_group.xe-connections.id}"]
    vpc_endpoint_type = "Interface"
    private_dns_enabled = true
    tags = {
        Name = "${lookup(var.project_name, var.env)}-vpc-endpoint"
    }
}