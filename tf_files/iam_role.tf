resource "aws_iam_policy" "ec2_policy" {
    name = "ec2_iam_policy"
    path="/"
    policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role" "ec2_role" {
    name = "ec2_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Sid = "testpolicy",
                Principal = {
                    Service = "ec2.amazonaws.com"
                },
                Action = [
                    "sts:AssumeRole"
                ]
            }
        ]
    })
}


resource "aws_iam_policy_attachment" "ec2_policy_role" {
    name = "ec2_attachment"
    roles = ["${aws_iam_role.ec2_role.name}"]
    policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2_profile"
    role = aws_iam_role.ec2_role.name
}