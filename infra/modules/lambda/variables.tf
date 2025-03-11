variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "filename" {
  description = "Path to the Lambda deployment package"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in the format of file.function"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime to use"
  type        = string
  default     = "python3.9"
}

variable "timeout" {
  description = "Function execution timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Amount of memory in MB for the function"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
  default     = "dev"
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs that the Lambda function will have access to"
  type        = list(string)
  default     = []
}

variable "s3_trigger_arn" {
  description = "ARN of the S3 bucket that will trigger the Lambda function"
  type        = string
  default     = ""
} 