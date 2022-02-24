variable "project_name" {
  type = map
  description = "Project name"
  default = {
    dev = "xe-dev-env"
    staging = "xe-staging-env"
    prod = "xe-prod-env"
  }
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "env" {
  description = "env: dev or staging or prod"
}

variable "PRIVATE_KEY_PATH" {
  default = "chrysanthos-inst-key"
}

variable "PUBLIC_KEY_PATH" {
  default = "chrysanthos-inst-key.pub"
}

variable "EC2_USER" {
  default = "ubuntu"
}

variable "AMI" {
  default = "ami-0d527b8c289b4af7f"
}

variable "instance_type" {
  type = map
  description = "Instance type of AWS EC2"
  default = {
    dev = "t2.micro"
    staging = "t2.micro"
    prod = "t2.micro"
  }
}

variable "priv_key_path" {
  default = "xe-code-challenge-key-pair"
}

variable "pub_key_path" {
  default = "xe-code-challenge-key-pair.pub"
}

variable "sns_name" {
  type = map
  description = "SNS Topic name"
  default = {
    dev = "xe-sns-topic"
    staging = "xe-sns-topic"
    prod = "prod-sns-topic"
  }
}

variable "sqs_updates_name" {
  type = map
  description = "SNS Topic name"
  default = {
    dev = "xe-sqs-updates"
    staging = "xe-sqs-updates"
    prod = "prod-sqs-updates"
  }
}
variable "account_id" {
  default = "5340-4446-7955"
}