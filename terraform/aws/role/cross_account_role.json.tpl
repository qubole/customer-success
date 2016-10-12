{
"Version": "2012-10-17",
"Statement": [
   {
   "Effect": "Allow",
   "Principal": {
                 "Service": "ec2.amazonaws.com"
                },
   "Action": "sts:AssumeRole"
   },
   {
   "Effect": "Allow",
   "Principal": {"AWS": "arn:aws:iam::${quboleAccountId}:root"},
   "Action": "sts:AssumeRole",
   "Condition": {"StringEquals": {"sts:ExternalId":"${externalId}"}}
   }
   ]
}