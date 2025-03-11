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

# S3 event notification for Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  count = var.enable_lambda_notification ? 1 : 0
  
  bucket = aws_s3_bucket.video_pipeline_input.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.notification_filter_prefix
    filter_suffix       = var.notification_filter_suffix
  }
  
  depends_on = [var.lambda_permission_depends_on]
}

# Create transcripts folder for transcription output
resource "aws_s3_object" "transcripts_folder" {
  bucket       = aws_s3_bucket.video_pipeline_input.id
  key          = "transcripts/"
  content_type = "application/x-directory"
  source       = "/dev/null"
} 