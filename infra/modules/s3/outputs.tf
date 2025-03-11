output "s3_bucket_name" {
  description = "Name of the S3 bucket for video pipeline input"
  value       = aws_s3_bucket.video_pipeline_input.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for video pipeline input"
  value       = aws_s3_bucket.video_pipeline_input.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket for video pipeline input"
  value       = aws_s3_bucket.video_pipeline_input.bucket_domain_name
}

output "bucket_id" {
  description = "The S3 bucket ID"
  value       = aws_s3_bucket.video_pipeline_input.id
} 