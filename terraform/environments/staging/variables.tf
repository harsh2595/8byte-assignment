variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used in resource names."
  type        = string
  default     = "8byte-assignment"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "staging"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "app_port" {
  description = "Application container port."
  type        = number
  default     = 4000
}

variable "image_tag" {
  description = "Docker image tag to deploy."
  type        = string
  default     = "latest"
}

variable "desired_count" {
  description = "Desired ECS task count."
  type        = number
  default     = 1
}

variable "ecs_cpu" {
  description = "ECS task CPU units."
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "ECS task memory in MB."
  type        = number
  default     = 512
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "PostgreSQL database username."
  type        = string
  default     = "appuser"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB."
  type        = number
  default     = 20
}

variable "backup_retention_days" {
  description = "RDS automated backup retention days."
  type        = number
  default     = 7
}

variable "log_retention_days" {
  description = "CloudWatch log retention days."
  type        = number
  default     = 14
}

variable "alb_access_logs_bucket" {
  description = "Optional S3 bucket for ALB access logs."
  type        = string
  default     = null
}

variable "alarm_email" {
  description = "Optional email address for CloudWatch alarm notifications."
  type        = string
  default     = null
}

variable "ecr_force_delete" {
  description = "Allow ECR repository deletion with images. Useful for disposable staging."
  type        = bool
  default     = true
}
