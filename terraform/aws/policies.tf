data "template_file" "storagePolicy" {
    template = "${file("${path.module}/policies/storage-policy.json.tpl")}"
    vars {
        defaultBucket = "${var.defaultBucket}"
  }
}

data "template_file" "computePolicy" {
    template = "${file("${path.module}/policies/compute-policy.json.tpl")}"

}

resource "aws_iam_policy" "computepolicy" {
    name = "QubolEec2Policy"
    policy = "${data.template_file.computePolicy.rendered}"
}


resource "aws_iam_policy" "s3policy" {
    name = "QuboleS3Policy"
    policy ="${data.template_file.storagePolicy.rendered}"
}


