output "bucket_id" {
    value = aws_s3_bucket.tf_remote_state.id
}

output "dynamodb_id" {
    value = aws_dynamodb_table.tf_remote_state_lock.id
}