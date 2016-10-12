#########################
#Create the IAM 


variable "computepolicy_arn" {
  
}

variable "s3policy_arn" {
  
}

resource "aws_iam_access_key" "computeUser" {
    user = "${aws_iam_user.quboleCompute.name}"
}

resource "aws_iam_access_key" "storageUser" {
    user = "${aws_iam_user.quboleStorage.name}"
}

resource "aws_iam_user" "quboleCompute" {
    name = "quboleCompute"
}

resource "aws_iam_user" "quboleStorage" {
    name = "quboleStorage"
}

resource "aws_iam_group" "quboleComputeGroup" {
    name = "quboleComputeGroup"
}

resource "aws_iam_group" "quboleStorageGroup" {
    name = "quboleStorageGroup"
}

resource "aws_iam_group_membership" "quboleStorageGroup" {
    name = "quboleStorageGroup"
    users = [
        "${aws_iam_user.quboleStorage.name}",
    ]
    group = "${aws_iam_group.quboleStorageGroup.name}"
}

resource "aws_iam_group_membership" "quboleComputeGroup" {
    name = "quboleComputeGroup"
    users = [
        "${aws_iam_user.quboleCompute.name}",
    ]
    group = "${aws_iam_group.quboleComputeGroup.name}"
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