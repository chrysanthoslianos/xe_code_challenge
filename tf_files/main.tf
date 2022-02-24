# assign a random int to the generated objects' name
resource "random_integer" "resource_id"{
    min = 1
    max = 10
}

# EC2 install to host AWSRedrive app
resource "aws_instance" "xe_code_challenge_ec2_instance" {
    # image and type
    ami = var.AMI
    instance_type = "${lookup(var.instance_type, var.env)}"
    #networking
    subnet_id = "${aws_subnet.xe-subnet-public.id}"
    vpc_security_group_ids = ["${aws_security_group.xe-connections.id}"]
    #networking /  access
    key_name = "${aws_key_pair.xe-code-challenge-key-pair.id}"

    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

    connection {
        user = "${var.EC2_USER}"
        private_key = "${file("${var.priv_key_path}")}"
    }
    metadata_options {
      http_endpoint = "enabled"
      instance_metadata_tags = "enabled"
    }
    tags = {
        Name = "${lookup(var.project_name, var.env)}-${random_integer.resource_id.result}"
    }
}

/* SSH access keypair
generate beforehand via: ssh-keygen -f xe-code-challenge-key-pair
*/
resource "aws_key_pair" "xe-code-challenge-key-pair" {
    key_name = "xe-code-challenge-key-pair"
    public_key = "${file("${var.pub_key_path}")}"
}

#SNS topic
resource "aws_sns_topic" "xe-code-challenge-sns-topic" {
    name = "${lookup(var.sns_name, var.env)}-${random_integer.resource_id.result}"
}

# SNS topic subscription
resource "aws_sns_topic_subscription" "xe-code-challenge-sqs-target" {
  topic_arn = "${aws_sns_topic.xe-code-challenge-sns-topic.arn}"
  protocol = "sqs"
  endpoint = "${aws_sqs_queue.xe-code-challenge-updates-queue.arn}"
}

# SNS topic policy
resource "aws_sns_topic_policy" "xe-code-challenge-topic-policy" {
    arn = aws_sns_topic.xe-code-challenge-sns-topic.arn
    policy = data.aws_iam_policy_document.xe-code-challenge-sns-policy-document.json
}


#SQS queue
resource "aws_sqs_queue" "xe-code-challenge-updates-queue" {
    name = "${lookup(var.sqs_updates_name, var.env)}-${random_integer.resource_id.result}"
    redrive_policy  = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.xe-code-challenge-dl_queue.arn}\",\"maxReceiveCount\":5}"
    visibility_timeout_seconds = 300
    tags = {
      Environment = var.env
    }
}
# SQS DL queue
resource "aws_sqs_queue" "xe-code-challenge-dl_queue" {
  name = "${lookup(var.sqs_updates_name, var.env)}-dl-${random_integer.resource_id.result}"
}

# SQS queue policy
resource "aws_sqs_queue_policy" "xe-code-challenge-queue-policy" {
  queue_url = "${aws_sqs_queue.xe-code-challenge-updates-queue.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:SendMessage","sqs:ReceiveMessage","sqs:ListQueues","sqs:GetQueueURL"],
      "Resource": "${aws_sqs_queue.xe-code-challenge-updates-queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.xe-code-challenge-sns-topic.arn}"
        }
      }
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "xe-code-challenge-sns-policy-document" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.xe-code-challenge-sns-topic.arn,
    ]

    sid = "__default_statement_ID"
  }
}