# S3 Module

This module provisions an S3 bucket for the Video Pipeline input layer with appropriate configuration for media file storage and processing.

## Features

- Globally unique bucket name generation
- Versioning for data integrity
- Server-side encryption (AES256)
- CORS configuration for web uploads
- Lifecycle rules for cost optimization

## Usage

```hcl
module "video_input_bucket" {
  source = "../../modules/s3"

  environment               = "dev"
  cors_allowed_origins      = ["https://example.com"]
  transition_standard_ia_days = 90
  transition_glacier_days   = 365
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2.0 |
| aws | ~> 4.16.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Deployment environment (dev or prod) | string | n/a | yes |
| cors_allowed_origins | List of origins allowed for CORS requests to the S3 bucket | list(string) | ["*"] | no |
| transition_standard_ia_days | Number of days before transitioning objects to STANDARD_IA storage class | number | 90 | no |
| transition_glacier_days | Number of days before transitioning objects to GLACIER storage class | number | 365 | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_name | Name of the S3 bucket for video pipeline input |
| s3_bucket_arn | ARN of the S3 bucket for video pipeline input |
| s3_bucket_domain_name | Domain name of the S3 bucket for video pipeline input |
| bucket_id | The S3 bucket ID | 