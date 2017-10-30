resource "aws_iam_instance_profile" "profile_1" {
  name = "${var.app_name}-profile-1.${var.tag_environment}"
  role = "${aws_iam_role.role.name}"
}

resource "aws_iam_role" "role" {
  name = "${var.app_name}-role.${var.tag_environment}"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "role_policy" {
    name = "ec2-describe-policy.${var.tag_environment}"
    role = "${aws_iam_role.role.id}"
    lifecycle {
      create_before_destroy = "true"
    }
    policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:AttachVolume"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}
