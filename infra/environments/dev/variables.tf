variable "environment" {
  description = "Deployment environment (dev and prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "cors_allowed_origins" {
  description = "List of origins allowed for CORS requests to the S3 bucket"
  type        = list(string)
  default     = ["*"]
}

variable "transition_standard_ia_days" {
  description = "Number of days before transitioning objects to STANDARD_IA storage class"
  type        = number
  default     = 90
}

variable "transition_glacier_days" {
  description = "Number of days before transitioning objects to GLACIER storage class"
  type        = number
  default     = 365
} 