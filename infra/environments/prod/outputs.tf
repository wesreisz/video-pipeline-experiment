output "s3_bucket_name" {
  description = "Name of the S3 bucket for video pipeline input"
  value       = module.video_input_bucket.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for video pipeline input"
  value       = module.video_input_bucket.s3_bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket for video pipeline input"
  value       = module.video_input_bucket.s3_bucket_domain_name
}

output "s3_bucket_region" {
  description = "Region where the S3 bucket is hosted"
  value       = var.aws_region
} 