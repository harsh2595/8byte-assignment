output "alb_dns_name" {
  description = "Public ALB DNS name."
  value       = module.alb.alb_dns_name
}

output "application_url" {
  description = "Application URL."
  value       = "http://${module.alb.alb_dns_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "RDS endpoint."
  value       = module.rds.db_endpoint
}

output "application_dashboard_name" {
  description = "CloudWatch application dashboard name."
  value       = module.monitoring.application_dashboard_name
}

output "database_dashboard_name" {
  description = "CloudWatch database dashboard name."
  value       = module.monitoring.database_dashboard_name
}

output "alb_access_logs_bucket" {
  description = "S3 bucket used for ALB access logs."
  value       = var.alb_access_logs_bucket == null ? aws_s3_bucket.alb_logs[0].id : var.alb_access_logs_bucket
}
