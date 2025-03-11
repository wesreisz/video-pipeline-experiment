terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16.0"
    }
  }
  required_version = ">= 1.2.0"

  # Uncomment and configure when ready for remote state
  # backend "s3" {
  #   bucket         = "video-pipeline-tf-state"
  #   key            = "environments/dev/terraform.tfstate"
  #   region         = "us-west-2"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

# Use the S3 module to create the input bucket
module "video_input_bucket" {
  source = "../../modules/s3"

  environment                 = var.environment
  cors_allowed_origins        = var.cors_allowed_origins
  transition_standard_ia_days = var.transition_standard_ia_days
  transition_glacier_days     = var.transition_glacier_days

  # Connect S3 bucket to Lambda function
  lambda_function_arn          = module.s3_event_processor.lambda_function_arn
  notification_filter_prefix   = ""
  notification_filter_suffix   = ""
  enable_lambda_notification   = true
  lambda_permission_depends_on = module.s3_event_processor.lambda_function_arn
}

# Lambda function to process S3 events
module "s3_event_processor" {
  source = "../../modules/lambda"

  function_name = "s3-event-processor-${var.environment}"
  description   = "Lambda function that processes S3 events and returns 'Hello World'"
  filename      = "${path.root}/../../../src/s3_event_processor/deploy/lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  environment   = var.environment

  s3_bucket_arns = [
    module.video_input_bucket.s3_bucket_arn,
    "${module.video_input_bucket.s3_bucket_arn}/*"
  ]

  s3_trigger_arn = module.video_input_bucket.s3_bucket_arn
} 