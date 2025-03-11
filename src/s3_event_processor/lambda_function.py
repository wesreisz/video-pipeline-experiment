import json
import logging
import os.path
import boto3
import uuid
from urllib.parse import unquote_plus

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize Transcribe client
transcribe = boto3.client('transcribe')

# Supported media formats for transcription
SUPPORTED_FORMATS = ['mp3', 'mp4', 'wav', 'flac', 'ogg', 'amr', 'webm']

def lambda_handler(event, context):
    """
    Lambda function that processes S3 events when new files are uploaded
    and starts transcription jobs for supported media files.
    
    Args:
        event (dict): Event data from S3
        context (LambdaContext): Runtime information
        
    Returns:
        dict: Response containing processing results
    """
    try:
        # Log the received event
        logger.info("Received event: %s", json.dumps(event))
        
        # Extract S3 bucket and key information from the event
        for record in event.get('Records', []):
            if record.get('eventSource') == 'aws:s3':
                bucket = record['s3']['bucket']['name']
                key = unquote_plus(record['s3']['object']['key'])
                
                # Extract just the filename from the key
                filename = os.path.basename(key)
                
                # Log detailed information about the uploaded file
                logger.info(f"File uploaded: s3://{bucket}/{key}")
                logger.info(f"Filename: {filename}")
                logger.info(f"File size: {record['s3']['object'].get('size', 'unknown')} bytes")
                
                # Check if the file has a supported format for transcription
                file_ext = filename.split('.')[-1].lower()
                if file_ext in SUPPORTED_FORMATS:
                    # Start transcription job
                    start_transcription_job(bucket, key, file_ext)
                else:
                    logger.info(f"File format '{file_ext}' is not supported for transcription.")
        
        # Return response
        response = {
            "statusCode": 200,
            "body": json.dumps({
                "message": "S3 event processed successfully",
                "bucket": bucket if 'bucket' in locals() else "Unknown",
                "key": key if 'key' in locals() else "Unknown",
                "filename": filename if 'filename' in locals() else "Unknown"
            })
        }
        
        return response
        
    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
        raise

def start_transcription_job(bucket, key, file_ext):
    """
    Start an AWS Transcribe job for the uploaded media file.
    
    Args:
        bucket (str): S3 bucket name
        key (str): S3 object key
        file_ext (str): File extension
    """
    try:
        # Create a unique job name
        job_name = f"transcribe-{uuid.uuid4()}"
        s3_uri = f"s3://{bucket}/{key}"
        
        # Get the media format (some formats need specific handling)
        media_format = file_ext
        if media_format == 'mp4':
            media_format = 'mp4'  # Could be mp4 or m4a
        
        # Start transcription job
        response = transcribe.start_transcription_job(
            TranscriptionJobName=job_name,
            Media={'MediaFileUri': s3_uri},
            MediaFormat=media_format,
            LanguageCode='en-US',  # Default language, could be made configurable
            OutputBucketName=bucket,
            OutputKey=f"transcripts/{os.path.splitext(key)[0]}.json"
        )
        
        logger.info(f"Started transcription job: {job_name}")
        logger.info(f"Transcription job response: {response}")
        
        return response
        
    except Exception as e:
        logger.error(f"Error starting transcription job: {str(e)}")
        raise 