variable "defaultBucket" {
  description = "Qubole Default S3 Location"
}

variable "prefix-tag" {
  description = "Qubole Tag to add to Resources"
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
