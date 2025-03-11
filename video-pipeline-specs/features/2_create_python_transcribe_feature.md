# Prompt: Update AWS Lambda Function for Transcription

## Objective
Update the Lambda function and Terraform configuration to add AWS Transcribe integration for processing uploaded media files.

## Instructions

1. **Enhance the Lambda Function:**
   - Add support for processing S3 events when new files are uploaded
   - Implement functionality to start transcription jobs using Amazon Transcribe
   - Add logic to check if file formats are supported for transcription
   - Implement proper error handling and logging

2. **Update AWS Service Integrations:**
   - Add EventBridge integration for transcription job completion events
   - Configure output storage for transcription results
   - Implement file archiving after successful transcription
   - Set up appropriate folder structure in S3

3. **Update Terraform Configuration:**
   - Update IAM policies to allow Lambda to use AWS Transcribe service
   - Add necessary permissions for S3 operations (read, write, delete)
   - Configure appropriate timeout and memory settings
   - Ensure proper resource naming and tagging

4. **Implement File Management:**
   - Create logic to store transcripts in a dedicated folder
   - Archive source files after processing
   - Handle different media formats appropriately
   - Validate file types before processing

## Expected Outcome
- A Lambda function that automatically starts transcription jobs for supported media formats
- Proper event handling for both S3 uploads and transcription completion events
- Organized storage with separate folders for transcripts and archived files
- Complete IAM permissions for AWS Transcribe and S3 operations

## Example Code

**Lambda Function**
```python
import json
import boto3
import logging
import os.path
import uuid
from urllib.parse import unquote_plus

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
transcribe = boto3.client('transcribe')
s3 = boto3.client('s3')

# Supported media formats for transcription
SUPPORTED_FORMATS = ['mp3', 'mp4', 'wav', 'flac', 'ogg', 'amr', 'webm']

def lambda_handler(event, context):
    """
    Lambda function that processes S3 events when new files are uploaded
    and starts transcription jobs for supported media files.
    """
    try:
        # Log the received event
        logger.info("Received event: %s", json.dumps(event))
        
        # Check if this is an S3 event or a transcription completion event
        if 'Records' in event:
            # This is an S3 event - handle file upload
            handle_s3_event(event)
        elif 'detail' in event and 'TranscriptionJobStatus' in event['detail']:
            # This is a transcription job completion event from EventBridge
            handle_transcription_completion(event)
        else:
            logger.info("Unknown event type received")
        
        # Return response
        response = {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Event processed successfully"
            })
        }
        
        return response
        
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        raise
```

**Terraform Configuration**
```hcl
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_transcribe_policy"
  description = "IAM policy for Lambda to access S3 and Transcribe"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "transcribe:StartTranscriptionJob",
          "transcribe:GetTranscriptionJob",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}
```
