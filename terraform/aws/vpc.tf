
resource "aws_vpc" "qubole-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags {
        Name = "qubole-vpc"
    }
}

##Subnets
##Use both private and public so we can 
##support multiAZ RDS
resource "aws_subnet" "qubole-public-a" {
    vpc_id                  = "${aws_vpc.qubole-vpc.id}"
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "${var.zoneA}"
    map_public_ip_on_launch = true

    tags {
        "Name" = "qubole-public-a"
    }
}

##Private Subnet A
resource "aws_subnet" "qubole-private-a" {
    vpc_id                  = "${aws_vpc.qubole-vpc.id}"
    cidr_block              = "10.0.3.0/24"
    availability_zone       = "${var.zoneA}"
    map_public_ip_on_launch = true

    tags {
        "Name" = "qubole-private-b"
    }
}

#Private Subnet B
resource "aws_subnet" "qubole-private-b" {
    vpc_id                  = "${aws_vpc.qubole-vpc.id}"
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "${var.zoneB}"
    map_public_ip_on_launch = true

    tags {
        "Name" = "qubole-private-a"
    }
}





#Route and Internet Gateway for inbound connections to 
#public subnet
#########################################

resource "aws_route_table" "nat_route_table" {
    vpc_id = "${aws_vpc.qubole-vpc.id}"
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.gw.id}"
    }
    tags {
        Name = "main"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.qubole-vpc.id}"
    tags {
        Name = "qubole_internet_gateway"
    }
}

##Nat Gateway

resource "aws_eip" "nat" {
  vpc = true

}

resource "aws_nat_gateway" "gw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.qubole-public-a.id}"
}

resource "aws_route_table" "priv_nat_route_table" {
    vpc_id = "${aws_vpc.qubole-vpc.id}"
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_nat_gateway.gw.id}"
    }
    tags {
        Name = "privateQubole"
    }
}

# route table associations
# public route tables
resource "aws_route_table_association" "qubole-public" {
    subnet_id = "${aws_subnet.qubole-public-a.id}"
    route_table_id = "${aws_route_table.nat_route_table.id}"
}

# route table associations
# public route tables
resource "aws_route_table_association" "qubole-private-a" {
    subnet_id = "${aws_subnet.qubole-private-a.id}"
    route_table_id = "${aws_route_table.priv_nat_route_table.id}"
}
resource "aws_route_table_association" "qubole-private-b" {
    subnet_id = "${aws_subnet.qubole-private-b.id}"
    route_table_id = "${aws_route_table.priv_nat_route_table.id}"
}
