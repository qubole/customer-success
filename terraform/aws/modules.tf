### Optional Modules that may be enabled

####################################################################
##IAM Role Craation for Qubole Access

#module "create_iam_role" {
#  source = "./role"
#  accountId = "${data.aws_caller_identity.current.account_id}"
#  computepolicy_arn = "${aws_iam_policy.computepolicy.arn}"
#  s3policy_arn = "${aws_iam_policy.s3policy.arn}"
#  externalId = "${var.externalId}"
#  quboleAccountId = "${var.quboleAccountId}"
#  prefix-tag = "${var.prefix-tag}"
#}

#variable "externalId" {
#	description = "ExternalId from Qubole - See QDS Control Panel"
#}

#variable "roleName" {
# description = "Role Name to Use"
#}

#variable "quboleAccountId" {
#  description = "ID of Qubole Account Id - See QDS Control Panel"
#}

#output "crossaccount_arn" {
#	value = "${module.create_iam_role.qdsrole}"
#}

####################################################################
##IAM User Craation for Qubole Access

module "create_iam_user" {
  source = "./user"
  computepolicy_arn = "${aws_iam_policy.computepolicy.arn}"
  s3policy_arn = "${aws_iam_policy.s3policy.arn}"
  prefix-tag = "${var.prefix-tag}"
}

output "compute_iam_access_key" {
    value = "${module.create_iam_user.compute_iam_access_key}"
}
output "compute_iam_secret_key" {
    value = "${module.create_iam_user.compute_iam_secret_key}"
}

output "storage_iam_access_key" {
    value = "${module.create_iam_user.storage_iam_access_key}"
}
output "storage_iam_secret_key" {
    value = "${module.create_iam_user.storage_iam_secret_key}"
}

output "storage_iam_secret_key_s3" {
    value = "${aws_iam_policy.s3policy.arn}"
}
output "storage_iam_secret_key_ec2" {
    value = "${aws_iam_policy.computepolicy.arn}"
}
####################################################################
# Bastion

module "create_bastion" {
  source = "./bastion"
  bastionInstanceType = "${var.bastionInstanceType}"
  bastionIncomingCidr = "${var.bastionIncomingCidr}"
  qubole-public-a = "${aws_subnet.qubole-public-a.id}"
  qubole-vpc = "${aws_vpc.qubole-vpc.id}"
  qubole-vpc-cider = "${var.vpcCidr}"
  prefix-tag = "${var.prefix-tag}"
}

variable "bastionIncomingCidr"{
  description ="Cidr block to allow Qubole to connect to bastion"
  default = "23.21.156.210/32"
}

variable "bastionInstanceType" {
  default = "t2.micro"
  description = "instance type to use for Bastion host"
}

#needed for metastore ingress rule
variable "vpcCidr" {
  description = "cidr address for vpc"
}

output "bastion_address" {
    value = "${module.create_bastion.bastion_address}"
}


####################################################################
## RDS for private metastore
#
# module "create_rds" {
#  source = "./rds"
#  qubole-vpc-id = "${aws_vpc.qubole-vpc.id}"
#  qubole-private-a-id = "${aws_subnet.qubole-private-a.id}"
#  qubole-private-b-id = "${aws_subnet.qubole-private-b.id}"
#  password = "${var.rdspassword}"
#  prefix-tag = "${var.prefix-tag}"
#  rds-identifier = "${var.rds-identifier}"
#}
#
#variable "rdspassword" {
#	description = "Qubole RDS Password"
#}

#variable "rds-identifier" {
#   description = "rds-identifier, unique name for account" 
#}

#output "rds_host" {
#  value = "${module.create_rds.rdshost}"
#}

####################################################################
## S3 Default Location Bucket

#module "s3defloc" {
#  source = "./s3defloc"
#  s3defloc = "${var.defaultBucket}"
#}



