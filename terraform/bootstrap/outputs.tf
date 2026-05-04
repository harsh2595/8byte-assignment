output "state_bucket_name" {
  description = "S3 bucket used for Terraform state."
  value       = aws_s3_bucket.state.id
}

output "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.locks.name
}
