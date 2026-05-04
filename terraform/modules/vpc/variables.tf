variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones used for subnet placement."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private application and database subnets."
  type        = list(string)
}

variable "tags" {
  description = "Common tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
