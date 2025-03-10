# Video Pipeline Architecture Documentation

This document outlines the complete architecture of our video processing and RAG (Retrieval-Augmented Generation) pipeline system.

## System Overview

```mermaid
graph TB
    subgraph Input ["Input Layer"]
        A[S3 Bucket] -->|Upload Event| B[EventBridge]
        style Input fill:#e6f3ff,stroke:#333,stroke-width:2px
    end
    
    subgraph Processing ["Processing Pipeline"]
        B --> C[Step Functions]
        C --> D[Transcription Service]
        D --> E[Text Processing]
        E --> F[Embedding Generation]
        style Processing fill:#fff3e6,stroke:#333,stroke-width:2px
    end
    
    subgraph Storage ["Storage Layer"]
        F --> G[Vector Database]
        G --> H[OpenSearch/Pinecone]
        style Storage fill:#e6ffe6,stroke:#333,stroke-width:2px
    end
    
    subgraph Query ["Query Pipeline"]
        I[API Gateway] --> J[Query Lambda]
        J --> K[Vector Search]
        K --> L[Context Assembly]
        L --> M[LLM Processing]
        M --> N[Response Generation]
        style Query fill:#ffe6e6,stroke:#333,stroke-width:2px
    end
    
    H --> K
```

## Step Functions Workflow

```mermaid
stateDiagram-v2
    [*] --> AudioUploaded
    AudioUploaded --> InitiateTranscription
    InitiateTranscription --> CheckTranscriptionStatus
    CheckTranscriptionStatus --> TranscriptionComplete : Success
    CheckTranscriptionStatus --> CheckTranscriptionStatus : In Progress
    TranscriptionComplete --> ProcessTranscript
    ProcessTranscript --> ChunkText
    ChunkText --> GenerateEmbeddings
    GenerateEmbeddings --> StoreVectorDB
    StoreVectorDB --> [*]
    
    state "Error Handling" as ErrorState
    InitiateTranscription --> ErrorState : Failure
    CheckTranscriptionStatus --> ErrorState : Failure
    ProcessTranscript --> ErrorState : Failure
    ChunkText --> ErrorState : Failure
    GenerateEmbeddings --> ErrorState : Failure
    StoreVectorDB --> ErrorState : Failure
    ErrorState --> [*]
```

## RAG Query Sequence

```mermaid
sequenceDiagram
    participant User
    participant API as API Gateway
    participant Lambda
    participant VDB as Vector Database
    participant LLM as SageMaker LLM
    
    User->>API: Submit Query
    activate API
    API->>Lambda: Trigger Lambda
    activate Lambda
    Lambda->>Lambda: Generate Query Embedding
    Lambda->>VDB: Search Similar Vectors
    activate VDB
    VDB-->>Lambda: Return Relevant Chunks
    deactivate VDB
    Lambda->>Lambda: Assemble Context
    Lambda->>LLM: Process Query + Context
    activate LLM
    LLM-->>Lambda: Generate Response
    deactivate LLM
    Lambda-->>API: Return Response
    deactivate Lambda
    API-->>User: Final Response
    deactivate API
```

## Component Architecture

```mermaid
classDiagram
    class AudioProcessor {
        +initiateTranscription()
        +checkStatus()
        +processTranscript()
    }
    
    class TextProcessor {
        +chunkText()
        +cleanTranscript()
        +validateChunks()
    }
    
    class EmbeddingGenerator {
        +generateEmbedding()
        +batchProcess()
        +validateEmbeddings()
    }
    
    class VectorDBManager {
        +storeEmbeddings()
        +searchSimilar()
        +updateIndex()
    }
    
    class QueryProcessor {
        +processQuery()
        +assembleContext()
        +generateResponse()
    }
    
    AudioProcessor --> TextProcessor
    TextProcessor --> EmbeddingGenerator
    EmbeddingGenerator --> VectorDBManager
    VectorDBManager --> QueryProcessor
```

## Deployment Architecture

```mermaid
graph LR
    subgraph AWS Cloud
        subgraph Processing Services
            SF[Step Functions]
            Lambda[Lambda Functions]
            SM[SageMaker Endpoints]
        end
        
        subgraph Storage Services
            S3[S3 Bucket]
            VDB[Vector Database]
        end
        
        subgraph API Layer
            AGW[API Gateway]
            ALB[Load Balancer]
        end
        
        subgraph Monitoring
            CW[CloudWatch]
            XRay[X-Ray]
        end
    end
    
    Client-->AGW
    AGW-->Lambda
    Lambda-->SF
    Lambda-->SM
    Lambda-->VDB
    SF-->S3
    
    style AWS Cloud fill:#f9f9f9,stroke:#333,stroke-width:2px
    style Processing Services fill:#fff3e6
    style Storage Services fill:#e6ffe6
    style API Layer fill:#e6f3ff
    style Monitoring fill:#ffe6e6
```

## Implementation Notes

1. **Audio Processing Pipeline:**
   - S3 event notifications trigger Step Functions workflow
   - Parallel processing for multiple audio files
   - Automatic retry mechanisms for failed steps
   - CloudWatch monitoring for each step

2. **Text Processing:**
   - Chunking by natural language boundaries
   - Metadata preservation for each chunk
   - Efficient batch processing

3. **Vector Database:**
   - OpenSearch with kNN plugin configuration
   - Optimized index settings
   - Backup and recovery procedures

4. **Query Pipeline:**
   - Load balancing for high availability
   - Response caching where appropriate
   - Error handling and fallback strategies

## Security Considerations

1. **IAM Roles and Permissions:**
   - Least privilege access
   - Service-specific roles
   - Resource-based policies

2. **API Security:**
   - API key management
   - Request throttling
   - Input validation

3. **Data Protection:**
   - Encryption at rest
   - Encryption in transit
   - Access logging

## Monitoring and Maintenance

1. **CloudWatch Metrics:**
   - Processing latency
   - Error rates
   - Resource utilization

2. **Alerting:**
   - Processing failures
   - API errors
   - Resource thresholds

3. **Maintenance:**
   - Regular backups
   - Index optimization
   - Model updates
