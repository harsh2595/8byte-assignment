variable "name" {
  description = "Name prefix for security groups."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "app_port" {
  description = "Container port exposed by the application."
  type        = number
}

variable "tags" {
  description = "Common tags applied to security groups."
  type        = map(string)
  default     = {}
}
