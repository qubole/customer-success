#########################################
#An Intance for Qubole Bastion

variable "bastionInstanceType" {
  
}

variable "bastionIncomingCidr" {
  
}

variable "qubole-public-a" {
  
}

variable "qubole-vpc" {
  
}


variable "prefix-tag" {
  
}


resource "aws_instance" "bastion" {
   ami = "${data.aws_ami.nat_ami.id}"
   instance_type = "${var.bastionInstanceType}"
   subnet_id = "${var.qubole-public-a}"
   associate_public_ip_address = true
   tags {
       Name = "Qubole Bastion"
       Prefix = "${var.prefix-tag}"
   }
   vpc_security_group_ids=["${aws_security_group.qubole-bastion.id}"]
}


#Security Group for Bastion
resource "aws_security_group" "qubole-bastion" {
    name = "qubole-bastion"
    description = "Allow inbound bastion traffic"
    vpc_id = "${var.qubole-vpc}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.bastionIncomingCidr}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

   tags {
       Prefix = "${var.prefix-tag}"
   }

}


output "bastion_address" {
    value = "${aws_instance.bastion.public_dns}"
}
output "aws_ami" {
    value = "${data.aws_ami.nat_ami.id}"
}

##Lookup AMI

data "aws_ami" "nat_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["qubole-bastion-hvm-amzn-linux*"]
  }
}