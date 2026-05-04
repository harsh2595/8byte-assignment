variable "name" {
  description = "Name prefix for monitoring resources."
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch metrics."
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name."
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name."
  type        = string
}

variable "db_instance_identifier" {
  description = "RDS instance identifier."
  type        = string
}

variable "alarm_email" {
  description = "Optional email address for alarm notifications."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to monitoring resources."
  type        = map(string)
  default     = {}
}
