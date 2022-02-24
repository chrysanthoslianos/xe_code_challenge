# internet gateway 
resource "aws_internet_gateway" "xe-igw" {
    vpc_id = "${aws_vpc.xe-vpc.id}"

    tags = {
        Name =  "${lookup(var.project_name, var.env)}-igw"
    }
}

/* custom route table: all instances reach the internet by the above gateway
route is below
*/
resource "aws_route_table" "xe-public-crt" {
    vpc_id = "${aws_vpc.xe-vpc.id}"
    
    route {
        cidr_block = "0.0.0.0/0"         
        gateway_id = "${aws_internet_gateway.xe-igw.id}" 
    }
    
    tags = {
        Name = "prod-public-crt"
    }
}

# associate our public subnet with the routing table to reach the internet
resource "aws_route_table_association" "xe-crta-public-subnet" {
    subnet_id = "${aws_subnet.xe-subnet-public.id}"
    route_table_id = "${aws_route_table.xe-public-crt.id}"
}

# using my personal Ip (https://www.whatsmyip.org/)
resource "aws_security_group" "xe-connections" {
    vpc_id = "${aws_vpc.xe-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${data.http.ip.body}/32"]
    }

    # another egress is required for AWSRedrive communication with consumer
    tags = {
        Name = "${lookup(var.project_name, var.env)}-connections"
    }
}

# fetch my public IP for ssh ingress
data "http" "ip" {
  url = "https://ifconfig.me"
}