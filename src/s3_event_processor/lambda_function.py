import json
import logging
import os.path
import boto3
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
    
    Args:
        event (dict): Event data from S3
        context (LambdaContext): Runtime information
        
    Returns:
        dict: Response containing processing results
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

def handle_s3_event(event):
    """
    Process S3 events when new files are uploaded.
    
    Args:
        event (dict): S3 event data
    """
    for record in event.get('Records', []):
        if record.get('eventSource') == 'aws:s3':
            bucket = record['s3']['bucket']['name']
            key = unquote_plus(record['s3']['object']['key'])
            
            # Only process files in the root directory
            if '/' in key and not key.startswith('archives/') and not key.startswith('transcripts/'):
                logger.info(f"Skipping file in subfolder: {key}")
                continue
                
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
                job_name = start_transcription_job(bucket, key, file_ext)
                
                # Store job name, bucket and key mapping for later use
                # Note: In a production environment, use DynamoDB to store this mapping
                logger.info(f"Started job {job_name} for file s3://{bucket}/{key}")
            else:
                logger.info(f"File format '{file_ext}' is not supported for transcription.")

def handle_transcription_completion(event):
    """
    Process transcription job completion events.
    
    Args:
        event (dict): EventBridge event data for transcription completion
    """
    try:
        # Extract job details
        job_name = event['detail']['TranscriptionJobName']
        job_status = event['detail']['TranscriptionJobStatus']
        
        logger.info(f"Received transcription completion event for job: {job_name}, status: {job_status}")
        
        if job_status == 'COMPLETED':
            # Get the transcription job details to find the source file
            job_details = transcribe.get_transcription_job(TranscriptionJobName=job_name)
            
            # Extract source file location
            media_uri = job_details['TranscriptionJob']['Media']['MediaFileUri']
            
            # Parse S3 URI to get bucket and key
            if media_uri.startswith('s3://'):
                parts = media_uri[5:].split('/', 1)
                if len(parts) == 2:
                    bucket = parts[0]
                    key = parts[1]
                    
                    # Archive the source file
                    archive_file(bucket, key)
                else:
                    logger.error(f"Invalid S3 URI format: {media_uri}")
            else:
                logger.error(f"Media URI is not an S3 URI: {media_uri}")
        else:
            logger.info(f"Transcription job {job_name} finished with status: {job_status}")
    
    except Exception as e:
        logger.error(f"Error processing transcription completion: {str(e)}")
        raise

def start_transcription_job(bucket, key, file_ext):
    """
    Start an AWS Transcribe job for the uploaded media file.
    
    Args:
        bucket (str): S3 bucket name
        key (str): S3 object key
        file_ext (str): File extension
        
    Returns:
        str: The name of the transcription job created
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
            OutputKey=f"transcripts/{os.path.splitext(os.path.basename(key))[0]}.json"
        )
        
        logger.info(f"Started transcription job: {job_name}")
        logger.info(f"Transcription job response: {response}")
        
        return job_name
        
    except Exception as e:
        logger.error(f"Error starting transcription job: {str(e)}")
        raise

def archive_file(bucket, key):
    """
    Move a processed file to the archives folder.
    
    Args:
        bucket (str): S3 bucket name
        key (str): S3 object key of the source file
    """
    try:
        # Create destination key for archive
        filename = os.path.basename(key)
        archive_key = f"archives/{filename}"
        
        logger.info(f"Archiving file s3://{bucket}/{key} to s3://{bucket}/{archive_key}")
        
        # Copy the file to the archives folder
        s3.copy_object(
            Bucket=bucket,
            CopySource={'Bucket': bucket, 'Key': key},
            Key=archive_key
        )
        
        # Delete the original file
        s3.delete_object(
            Bucket=bucket,
            Key=key
        )
        
        logger.info(f"Successfully archived file to s3://{bucket}/{archive_key}")
        
    except Exception as e:
        logger.error(f"Error archiving file: {str(e)}")
        raise 