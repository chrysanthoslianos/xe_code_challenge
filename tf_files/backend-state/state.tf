# remote state S3 bucket
resource "aws_s3_bucket" "tf_remote_state" {
    bucket = "xe-code-challenge-state-bucket"
    lifecycle {
      prevent_destroy = true
    }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "tf_remote_state_versioning" {
    bucket = aws_s3_bucket.tf_remote_state.id
    versioning_configuration {
      status = "Enabled"
    }
}

# S3 bucket ACL
resource "aws_s3_bucket_acl" "tf_remote_state_acl" {
    bucket = aws_s3_bucket.tf_remote_state.id
    acl = "private"
}

# associate S3 policy with bucket
resource "aws_s3_bucket_policy" "prevent_s3_delete_policy" {
    bucket = aws_s3_bucket.tf_remote_state.id
    policy= data.aws_iam_policy_document.prevent_s3_delete_action.json
}

# prevent Deletion of S3 bucket
data "aws_iam_policy_document" "prevent_s3_delete_action" {
    statement {
        principals {
            type = "AWS"
            identifiers = ["5340-4446-7955"]
        }
      actions = ["s3:DeleteBucket"]
      resources = [aws_s3_bucket.tf_remote_state.arn]
      effect = "Deny"
    }
}

# DynamoDB to handle state lock
resource "aws_dynamodb_table" "tf_remote_state_lock" {
    hash_key = "LockID"
    name = "tf_state_lock"
    read_capacity = "5"
    write_capacity = "5"
    attribute {
      name = "LockID"
      type = "S"
    }
}