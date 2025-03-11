variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-eest-1"
}

variable "cors_allowed_origins" {
  description = "List of origins allowed for CORS requests to the S3 bucket"
  type        = list(string)
  default     = ["https://wesleyreisz.com"]
}

variable "transition_standard_ia_days" {
  description = "Number of days before transitioning objects to STANDARD_IA storage class"
  type        = number
  default     = 30
}

variable "transition_glacier_days" {
  description = "Number of days before transitioning objects to GLACIER storage class"
  type        = number
  default     = 90
} 