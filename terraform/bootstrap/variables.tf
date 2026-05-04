variable "aws_region" {
  description = "AWS region used for Terraform state resources."
  type        = string
  default     = "ap-south-1"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
  default     = "8byte-terraform-locks"
}

variable "force_destroy" {
  description = "Whether to allow deleting the state bucket even when objects exist. Keep false for real use."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default = {
    Project   = "8byte-assignment"
    ManagedBy = "terraform"
  }
}
