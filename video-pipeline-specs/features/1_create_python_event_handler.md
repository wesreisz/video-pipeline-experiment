# Prompt: Create an S3-Triggered Lambda Function

## Objective
Create an AWS Lambda function that is triggered by S3 events when new files are uploaded to a specified S3 bucket. The function should log details about the uploaded file and return a "Hello World" message.

## Instructions

1. **Create the Lambda Function Code:**
   - Write a Python function named `lambda_handler` that:
     - Accepts `event` and `context` as parameters.
     - Logs the received S3 event.
     - Extracts the bucket name and object key from the event.
     - Logs the full S3 path and the filename.
     - Returns a JSON response with a "Hello World" message and details about the uploaded file.

2. **Set Up the Project Structure:**
   - Create a directory named `src/s3_event_processor` to store the Lambda function code.
   - Add a `lambda_function.py` file with the function code.
   - Add a `requirements.txt` file if any external dependencies are needed (for this simple function, it can be empty).

3. **Package the Lambda Function:**
   - Write a `deploy.sh` script to package the Lambda function into a ZIP file for deployment.
   - Ensure the script creates a `deploy` directory and packages the Python file into `lambda_function.zip`.

4. **Update Terraform Configuration:**
   - Create a Terraform module for the Lambda function in `infra/modules/lambda`.
   - Define resources for the Lambda function, IAM role, and S3 bucket notification.
   - Ensure the Lambda function is triggered by S3 events using the `aws_s3_bucket_notification` resource.

5. **Deploy the Infrastructure:**
   - Use Terraform to deploy the Lambda function and S3 bucket configuration.
   - Ensure the Lambda function is correctly triggered by S3 events.

6. **Test the Deployment:**
   - Upload a test file to the S3 bucket.
   - Check the CloudWatch logs to verify the Lambda function was triggered and logged the expected information.

## Expected Outcome
- A Lambda function that logs and responds to S3 file upload events.
- The function is automatically triggered when files are uploaded to the specified S3 bucket.
- The complete event information is logged to CloudWatch.
- The function returns a response containing "Hello World" and details of the uploaded file.

## Example Code

**lambda_function.py**
```python
import json
import logging
import os.path

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        logger.info("Received event: %s", json.dumps(event))
        for record in event.get('Records', []):
            if record.get('eventSource') == 'aws:s3':
                bucket = record['s3']['bucket']['name']
                key = record['s3']['object']['key']
                filename = os.path.basename(key)
                logger.info(f"File uploaded: s3://{bucket}/{key}")
                logger.info(f"Filename: {filename}")
        response = {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Hello World",
                "bucket": bucket,
                "key": key,
                "filename": filename
            })
        }
        return response
    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
        raise
```

**deploy.sh**
```bash
#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEPLOY_DIR="${SCRIPT_DIR}/deploy"
ZIPFILE="${DEPLOY_DIR}/lambda_function.zip"
echo "Packaging Lambda function..."
mkdir -p "${DEPLOY_DIR}"
rm -f "${ZIPFILE}"
cd "${SCRIPT_DIR}"
zip -r "${ZIPFILE}" ./*.py
echo "Lambda package created at ${ZIPFILE}"
echo "Done."