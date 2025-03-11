import json
import logging
import os.path

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function that processes S3 events when new files are uploaded.
    
    Args:
        event (dict): Event data from S3
        context (LambdaContext): Runtime information
        
    Returns:
        dict: Response containing "Hello World" message
    """
    try:
        # Log the received event
        logger.info("Received event: %s", json.dumps(event))
        
        # Extract S3 bucket and key information from the event
        for record in event.get('Records', []):
            if record.get('eventSource') == 'aws:s3':
                bucket = record['s3']['bucket']['name']
                key = record['s3']['object']['key']
                
                # Extract just the filename from the key
                filename = os.path.basename(key)
                
                # Log detailed information about the uploaded file
                logger.info(f"File uploaded: s3://{bucket}/{key}")
                logger.info(f"Filename: {filename}")
                logger.info(f"File size: {record['s3']['object'].get('size', 'unknown')} bytes")
                
        # Return "Hello World" response
        response = {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Hello World",
                "bucket": bucket if 'bucket' in locals() else "Unknown",
                "key": key if 'key' in locals() else "Unknown",
                "filename": filename if 'filename' in locals() else "Unknown"
            })
        }
        
        return response
        
    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
        raise 