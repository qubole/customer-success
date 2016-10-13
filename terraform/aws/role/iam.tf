#########################
#Create the IAM Role



variable "accountId" {
  
}

variable "computepolicy_arn" {
  
}

variable "s3policy_arn" {
  
}

variable "externalId" {
  
}

variable "quboleAccountId" {
  
}



resource "aws_iam_policy_attachment" "s3" {
    name = "s3-attachment2"
    roles = ["${aws_iam_role.qdsrole.name}"]
    policy_arn = "${var.s3policy_arn}"
}

resource "aws_iam_policy_attachment" "compute" {
    name = "compute-attachment1"
    roles = ["${aws_iam_role.qdsrole.name}"]
    policy_arn = "${var.computepolicy_arn}"
}

resource "aws_iam_policy_attachment" "qdscap" {
    name = "qdscap-attachment1"
    roles = ["${aws_iam_role.qdsrole.name}"]
    policy_arn = "${aws_iam_policy.qubole-crossaccount-policy.arn}"
}


data "template_file" "rolePolicy" {
    template = "${file("${path.module}/iam_role.json.tpl")}"
      vars {
        accountId = "${var.accountId}"
  }
}

data "template_file" "crossAccountPolicy" {
    template = "${file("${path.module}/cross_account_role.json.tpl")}"
      vars {
        externalId = "${var.externalId}"
        quboleAccountId  = "${var.quboleAccountId}"
  }
}



resource "aws_iam_policy" "qubole-crossaccount-policy" {
    name = "qubole-crossaccount-policy"
    policy = "${data.template_file.rolePolicy.rendered}"
}

resource "aws_iam_role" "qdsrole" {
    name = "QDSIAMRole"
    assume_role_policy = "${data.template_file.crossAccountPolicy.rendered}"
}

output qdsrole {
  value = "${aws_iam_role.qdsrole.arn}"
}