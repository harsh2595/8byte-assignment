variable "name" {
  description = "Name prefix for ECS resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL."
  type        = string
}

variable "image_tag" {
  description = "Docker image tag deployed to ECS."
  type        = string
}

variable "app_port" {
  description = "Application container port."
  type        = number
}

variable "desired_count" {
  description = "Desired ECS task count."
  type        = number
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
}

variable "memory" {
  description = "Fargate task memory in MB."
  type        = number
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks."
  type        = list(string)
}

variable "security_group_id" {
  description = "Application security group ID."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN."
  type        = string
}

variable "db_host" {
  description = "PostgreSQL host."
  type        = string
}

variable "db_port" {
  description = "PostgreSQL port."
  type        = number
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
}

variable "db_user" {
  description = "PostgreSQL database username."
  type        = string
}

variable "db_password_secret_arn" {
  description = "Secrets Manager ARN containing JSON key password."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

variable "tags" {
  description = "Common tags applied to ECS resources."
  type        = map(string)
  default     = {}
}
