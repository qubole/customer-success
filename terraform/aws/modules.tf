### Optional Modules that may be enabled

####################################################################
##IAM Role Craation for Qubole Access

module "create_iam_role" {
  source = "./role"
  accountId = "${data.aws_caller_identity.current.account_id}"
  computepolicy_arn = "${aws_iam_policy.computepolicy.arn}"
  s3policy_arn = "${aws_iam_policy.s3policy.arn}"
  externalId = "${var.externalId}"
  quboleAccountId = "${var.quboleAccountId}"
}

variable "externalId" {
	description = "ExternalId from Qubole - See QDS Control Panel"
}

variable "quboleAccountId" {
  description = "ID of Qubole Account Id - See QDS Control Panel"
}

output "crossaccount_arn" {
	value = "${module.create_iam_role.qdsrole}"
}

####################################################################
##IAM User Craation for Qubole Access

#module "create_iam_user" {
#  source = "./user"
#  computepolicy_arn = "${aws_iam_policy.computepolicy.arn}"
#  s3policy_arn = "${aws_iam_policy.s3policy.arn}"
#}

#output "compute_iam_access_key" {
#    value = "${module.create_iam_user.compute_iam_access_key}"
#}
#output "compute_iam_secret_key" {
#    value = "${module.create_iam_user.compute_iam_secret_key}"
#}
#
#output "storage_iam_access_key" {
#    value = "${module.create_iam_user.storage_iam_access_key}"
#}
#output "storage_iam_secret_key" {
#    value = "${module.create_iam_user.storage_iam_secret_key}"
#}

####################################################################
# Bastion

module "create_bastion" {
  source = "./bastion"
  bastionInstanceType = "${var.bastionInstanceType}"
  bastionIncomingCidr = "${var.bastionIncomingCidr}"
  qubole-public-a = "${aws_subnet.qubole-public-a.id}"
  qubole-vpc = "${aws_vpc.qubole-vpc.id}"
}

output "bastion_address" {
    value = "${module.create_bastion.bastion_address}"
}

####################################################################
## RDS for private metastore

#module "create_rds" {
#  source = "./rds"
#  qubole-vpc-id = "${aws_vpc.qubole-vpc.id}"
#  qubole-private-a-id = "${aws_subnet.qubole-private-a.id}"
#  qubole-private-b-id = "${aws_subnet.qubole-private-b.id}"
#  password = "${var.rdspassword}"
#}

#variable "rdspassword" {
#	description = "Qubole RDS Password"
#}

####################################################################
## S3 Default Location Bucket

#module "s3defloc" {
#  source = "./s3defloc"
#  s3defloc = "${var.defaultBucket}"
#}



