variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Valid values for environment are: dev or prod."
  }
}

variable "cors_allowed_origins" {
  description = "List of origins allowed for CORS requests to the S3 bucket"
  type        = list(string)
  default     = ["*"]
  
  validation {
    condition     = length(var.cors_allowed_origins) > 0
    error_message = "Must specify at least one allowed origin for CORS."
  }
}

variable "transition_standard_ia_days" {
  description = "Number of days before transitioning objects to STANDARD_IA storage class"
  type        = number
  default     = 90
  
  validation {
    condition     = var.transition_standard_ia_days >= 30
    error_message = "Standard-IA transition must be at least 30 days."
  }
}

variable "transition_glacier_days" {
  description = "Number of days before transitioning objects to GLACIER storage class"
  type        = number
  default     = 365
  
  validation {
    condition     = var.transition_glacier_days >= 90
    error_message = "Glacier transition must be at least 90 days."
  }
} 