# RAG Pipeline Implementation Prompt

Design and implement a Retrieval-Augmented Generation (RAG) pipeline that integrates with an API Gateway endpoint. The pipeline should follow these steps:

1. **User Query Ingestion:**  
   - The API Gateway exposes an HTTP endpoint that accepts POST requests containing a user query.

2. **Vector Search for Relevant Context:**  
   - When the endpoint is invoked, a Lambda function is triggered.
   - This Lambda function first generates an embedding for the user query by calling a SageMaker endpoint that hosts an embedding model.
   - The generated embedding is then used to perform a vector similarity search on a vector database (such as Amazon OpenSearch with the kNN plugin) to retrieve the top-N relevant text chunks (e.g., from conference transcripts).

3. **Context Assembly:**  
   - The retrieved text chunks are concatenated or otherwise assembled to create a comprehensive context that supports the user query.

4. **Query Augmentation and LLM Processing:**  
   - The Lambda function then augments the original query with the assembled context.
   - This augmented prompt is sent to another SageMaker endpoint that hosts a large language model (LLM) to generate a context-aware response.

5. **Return Response:**  
   - The generated response from the LLM is formatted and returned via API Gateway as the final output to the user.

6. **Implementation Considerations:**  
   - Use AWS Lambda functions to handle the vector search, context assembly, and LLM invocation.
   - Ensure the pipeline is scalable by leveraging SageMaker endpoints for both embedding generation and the LLM.
   - Incorporate error handling, logging, and proper IAM roles for secure access to each service.
   - Optionally, consider using AWS Step Functions to orchestrate the overall workflow if additional steps or parallel processing are required.

---

**Task:**  
Please generate a detailed design document, including pseudocode examples, architectural diagrams, and deployment guidelines, that fully describes this RAG pipeline implementation with the API endpoint integrated with SageMaker services.
