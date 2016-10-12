variable "defaultBucket" {
  description = "Qubole Default S3 Location"
}


variable "bastionIncomingCidr"{
	description ="Cidr block to allow Qubole to connect to bastion"
	default = "23.21.156.210/32"
}

variable "bastionInstanceType" {
  default = "t2.micro"
  description = "instance type to use for Bastion host"
}

variable "zoneA" {
  default = "us-east-1a"
}
variable "zoneB" {
  default = "us-east-1c"
}

variable aws_region{
	default = "us-east-1"
}
