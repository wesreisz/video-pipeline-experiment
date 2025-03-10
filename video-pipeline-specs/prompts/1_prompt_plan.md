1. Project Setup & S3 Configuration

Prompt:
"Generate CloudFormation (or Terraform) code to create an S3 bucket that will store audio files. Include an S3 event notification (or an EventBridge rule) that triggers a Lambda function when a new file is uploaded."
2. Lambda Function: Start Transcription Job

Prompt:
"Generate a Python Lambda function that receives an S3 event, extracts the bucket name and key, and then calls Amazon Transcribe to start a transcription job. The function should set the output bucket and include basic error handling."
3. Lambda Function: Poll Transcription Status

Prompt:
"Generate a Python Lambda function that polls Amazon Transcribe for the status of a transcription job using the job name. The function should implement retries or backoff logic until the job is complete or an error occurs."
4. Lambda Function: Retrieve Transcript

Prompt:
"Generate a Python Lambda function that retrieves the transcript file from Amazon Transcribe output (stored in S3) once the transcription job completes. The function should parse the transcript JSON and extract the text content."
5. Lambda Function: Chunk Transcript and Enrich Metadata

Prompt:
"Generate a Python Lambda function that takes the transcript text, splits it into smaller chunks (by sentence, paragraph, or token count), and attaches metadata (like original file name, chunk index, etc.). Use a simple chunking algorithm for demonstration."
6. Embedding Generation (Using SageMaker or Lambda)

Prompt Option A (SageMaker):
"Generate code for a SageMaker endpoint deployment using a pre-trained text embedding model (e.g., Sentence Transformers or BERT). Include a sample Python client function that calls this endpoint to generate embeddings for a given text chunk."
Prompt Option B (Lambda):
"Generate a lightweight Python Lambda function that simulates generating text embeddings for a given text chunk (e.g., returns a dummy embedding vector)."
7. Lambda Function: Store Embeddings in Vector Database

Prompt:
"Generate a Python Lambda function that takes the embedding vector along with metadata and stores it in a vector database. Use Amazon OpenSearch Service (with the kNN plugin) as an example. The code should show how to index documents in OpenSearch."
8. AWS Step Functions State Machine Definition

Prompt:
"Generate a JSON definition (Amazon States Language) for an AWS Step Functions state machine that orchestrates the workflow. Include states for: starting the transcription job, polling for completion, retrieving the transcript, chunking the transcript, generating embeddings (using Map state for parallel processing), and storing embeddings in the vector database. Also include error handling and retry policies."
9. API Gateway and Query Handling Lambda Function

Prompt:
"Generate a Python Lambda function that is integrated with API Gateway to handle user queries. This function should:
Parse the query from the request,
Call the vector database (e.g., using OpenSearch's kNN search) to retrieve the top-N similar text chunks,
Assemble the context from those chunks, and
Call an LLM endpoint (simulate with a placeholder URL) by passing the query and context,
Finally, return the answer to the user.
Also include sample code for a REST API integration with API Gateway."
10. IAM Roles and Security Policies

Prompt:
"Generate a set of IAM policies (in JSON) for the Lambda functions and Step Functions that provide the minimum required permissions to interact with S3, Amazon Transcribe, SageMaker (or Lambda), OpenSearch, and API Gateway. Include policies for logging to CloudWatch."
11. CloudWatch Logging & Monitoring Setup

Prompt:
"Generate instructions or CloudFormation code to enable detailed CloudWatch logging and monitoring for all Lambda functions and the Step Functions state machine. Include setting up CloudWatch Alarms for failures or timeouts."
12. Documentation & Mermaid Diagram

Prompt:
"Generate a Mermaid diagram code snippet that visualizes the overall architecture and workflow of the system, including components like S3, Lambda functions, Step Functions, Transcribe, SageMaker/embedding service, the vector database, and API Gateway."