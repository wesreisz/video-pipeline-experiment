# Prompt: Update AWS Lambda Function and Terraform Configuration for Transcription


Read file: video-pipeline-specs/features/1_create_python_event_handler.md
Read file: src/s3_event_processor/lambda_function.py
Read folder: infra/modules/lambda

## AWS Lambda Function and Terraform Configuration for Transcription

### Lambda Function Details
- The function should process S3 events when new files are uploaded and start transcription jobs using Amazon Transcribe.
- Example code for the Lambda function includes:
  - Logging the received S3 event.
  - Extracting the bucket name and object key.
  - Checking if the file format is supported for transcription.
  - Starting a transcription job using the `boto3` library.

```python
# Example Lambda function code
import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

transcribe = boto3.client('transcribe')

SUPPORTED_FORMATS = ['mp3', 'mp4', 'wav', 'flac', 'ogg', 'amr', 'webm']

# Lambda function handler

def lambda_handler(event, context):
    logger.info('Received event: %s', json.dumps(event))
    
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        if not key.split('.')[-1] in SUPPORTED_FORMATS:
            logger.warning('File format not supported for transcription: %s', key)
            continue
        
        job_name = key.replace('/', '_')
        job_uri = f's3://{bucket}/{key}'
        
        try:
            response = transcribe.start_transcription_job(
                TranscriptionJobName=job_name,
                Media={'MediaFileUri': job_uri},
                MediaFormat=key.split('.')[-1],
                LanguageCode='en-US'
            )
            logger.info('Started transcription job: %s', response)
        except Exception as e:
            logger.error('Error starting transcription job: %s', e)
```

### Terraform Configuration Details
- Define a Terraform module for the Lambda function, including necessary IAM roles and permissions.
- Example Terraform code includes:
  - The definition of the Lambda function resource in `infra/modules/lambda/main.tf`.
  - IAM policies that allow the Lambda function to start transcription jobs and access S3 buckets.

```hcl
# Example Terraform configuration
resource "aws_lambda_function" "s3_event_processor" {
  filename         = "lambda_function_payload.zip"
  function_name    = "s3_event_processor"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  runtime          = "python3.8"
  
  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
  
  tags = {
    Environment = "production"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "IAM policy for Lambda to access S3 and Transcribe"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "transcribe:StartTranscriptionJob",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}
```
