variable "name" {
  description = "Name prefix for ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB security group ID."
  type        = string
}

variable "app_port" {
  description = "Application target port."
  type        = number
}

variable "health_check_path" {
  description = "ALB health check path."
  type        = string
  default     = "/health"
}

variable "access_logs_bucket" {
  description = "Optional S3 bucket name for ALB access logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to ALB resources."
  type        = map(string)
  default     = {}
}
