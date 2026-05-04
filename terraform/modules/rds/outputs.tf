output "db_instance_identifier" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.id
}

output "db_endpoint" {
  description = "RDS endpoint."
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "RDS hostname."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "db_password_secret_arn" {
  description = "Secrets Manager ARN containing the database password."
  value       = aws_secretsmanager_secret.db_password.arn
  sensitive   = true
}
