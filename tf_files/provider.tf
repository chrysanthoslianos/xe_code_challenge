provider "aws" {
    region = "${var.aws_region}"
}

terraform {
  backend "s3" {
      bucket = "xe-code-challenge-state-bucket"
      key = "terraform.tfstate"
      region = "eu-central-1"
      encrypt = true
      dynamodb_table = "tf_state_lock"
  }
}