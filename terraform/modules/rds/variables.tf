variable "name" {
  description = "Name prefix for RDS resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID allowed to access PostgreSQL."
  type        = string
}

variable "db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
}

variable "backup_retention_days" {
  description = "Automated backup retention in days."
  type        = number
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ for RDS."
  type        = bool
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on deletion."
  type        = bool
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier when skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to RDS resources."
  type        = map(string)
  default     = {}
}
