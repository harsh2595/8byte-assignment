output "application_dashboard_name" {
  description = "Application dashboard name."
  value       = aws_cloudwatch_dashboard.application.dashboard_name
}

output "database_dashboard_name" {
  description = "Database dashboard name."
  value       = aws_cloudwatch_dashboard.database.dashboard_name
}

output "alerts_topic_arn" {
  description = "SNS topic ARN for alerts, if enabled."
  value       = try(aws_sns_topic.alerts[0].arn, null)
}
