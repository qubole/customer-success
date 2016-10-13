variable s3defloc {
	
}

resource "aws_s3_bucket" "defloc" {
    bucket = "${var.s3defloc}"
    acl = "private"

    tags {
        Name = "Qubole Defloc"
    }
}

output s3defloc {
	value = "${var.s3defloc}"
}