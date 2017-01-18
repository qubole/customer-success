{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetBucketAcl",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": [
        "arn:aws:s3:::${defaultBucket}/*",
        "arn:aws:s3:::${defaultBucket}",
        "arn:aws:s3:::paid-qubole",
        "arn:aws:s3:::paid-qubole/*"
      ]
    }
  ]
}