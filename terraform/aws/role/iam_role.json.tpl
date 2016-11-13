{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:GetInstanceProfile",
            "Resource": "arn:aws:iam::${accountId}:instance-profile/${roleName}"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${accountId}:role/${roleName}"
        }
    ]
}