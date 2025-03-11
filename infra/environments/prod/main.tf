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
  #   key            = "environments/prod/terraform.tfstate"
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

  environment               = var.environment
  cors_allowed_origins      = var.cors_allowed_origins
  transition_standard_ia_days = var.transition_standard_ia_days
  transition_glacier_days   = var.transition_glacier_days
} 