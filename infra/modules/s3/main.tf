# S3 bucket for video/audio file uploads
resource "aws_s3_bucket" "video_pipeline_input" {
  bucket = "video-pipeline-input-${var.environment}-${random_string.bucket_suffix.result}"
  
  tags = {
    Name        = "VideoPipelineInput"
    Environment = var.environment
    Project     = "VideoPipeline"
    ManagedBy   = "Terraform"
    Component   = "Storage"
  }
}

# Generate a random suffix for globally unique S3 bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Configure bucket versioning (recommended for data integrity)
resource "aws_s3_bucket_versioning" "input_bucket_versioning" {
  bucket = aws_s3_bucket.video_pipeline_input.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Set appropriate CORS configuration for web uploads
resource "aws_s3_bucket_cors_configuration" "input_bucket_cors" {
  bucket = aws_s3_bucket.video_pipeline_input.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Set bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "input_bucket_encryption" {
  bucket = aws_s3_bucket.video_pipeline_input.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Set lifecycle rule for old uploads
resource "aws_s3_bucket_lifecycle_configuration" "input_bucket_lifecycle" {
  bucket = aws_s3_bucket.video_pipeline_input.id

  rule {
    id      = "archive-old-objects"
    status  = "Enabled"

    transition {
      days          = var.transition_standard_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.transition_glacier_days
      storage_class = "GLACIER"
    }
  }
} 