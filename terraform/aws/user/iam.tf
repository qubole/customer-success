#########################
#Create the IAM User


variable "computepolicy_arn" {
  
}

variable "s3policy_arn" {
  
}

variable "prefix-tag" {
  
}



resource "aws_iam_access_key" "computeUser" {
    user = "${aws_iam_user.quboleCompute.name}"
}

resource "aws_iam_access_key" "storageUser" {
    user = "${aws_iam_user.quboleStorage.name}"
}

resource "aws_iam_user" "quboleCompute" {
    name = "${var.prefix-tag}-quboleCompute"
}

resource "aws_iam_user" "quboleStorage" {
    name = "${var.prefix-tag}-quboleStorage"
}

resource "aws_iam_group" "quboleComputeGroup" {
    name = "${var.prefix-tag}-quboleComputeGroup"
}

resource "aws_iam_group" "quboleStorageGroup" {
    name = "${var.prefix-tag}-quboleStorageGroup"
}

resource "aws_iam_group_membership" "quboleStorageGroup" {
    name = "${var.prefix-tag}-quboleStorageGroup"
    users = [
        "${aws_iam_user.quboleStorage.name}",
    ]
    group = "${aws_iam_group.quboleStorageGroup.name}"
}

resource "aws_iam_group_membership" "quboleComputeGroup" {
    name = "${var.prefix-tag}-quboleComputeGroup"
    users = [
        "${aws_iam_user.quboleCompute.name}",
    ]
    group = "${aws_iam_group.quboleComputeGroup.name}"
}


resource "aws_iam_group_policy_attachment" "compute-attach" {
    group = "${aws_iam_group.quboleComputeGroup.name}"
    policy_arn = "${var.computepolicy_arn}"
}

resource "aws_iam_group_policy_attachment" "s3-attach" {
    group = "${aws_iam_group.quboleStorageGroup.name}"
    policy_arn = "${var.s3policy_arn}"
}

output "compute_iam_access_key" {
    value = "${aws_iam_access_key.computeUser.id}"
}
output "compute_iam_secret_key" {
    value = "${aws_iam_access_key.computeUser.secret}"
}

output "storage_iam_access_key" {
    value = "${aws_iam_access_key.storageUser.id}"
}
output "storage_iam_secret_key" {
    value = "${aws_iam_access_key.storageUser.secret}"
}