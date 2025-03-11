# Video Pipeline Infrastructure

This directory contains Terraform code for deploying and managing the Video Pipeline infrastructure components as specified in the architecture documentation.

## Components

The Video Pipeline infrastructure includes:

- S3 bucket for video/audio file input storage
- (Future) EventBridge for event handling
- (Future) Step Functions for workflow orchestration
- (Future) Lambda functions for processing
- (Future) Vector database for embeddings storage

## Directory Structure

```
infra/
├── environments/        # Environment-specific configurations
│   ├── dev/             # Development environment
│   └── prod/            # Production environment
├── modules/             # Reusable infrastructure modules
│   ├── s3/              # S3 bucket module
│   ├── lambda/          # (Future) Lambda functions module
│   ├── step_functions/  # (Future) Step Functions module
│   └── vector_db/       # (Future) Vector database module
└── README.md            # This documentation
```

## Usage

### Prerequisites

- Terraform >= 1.2.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create required resources

### Deployment

1. Choose the environment you want to deploy to (dev or prod)

2. Initialize the Terraform working directory:

```bash
cd infra/environments/dev  # Or prod
terraform init
```

3. Review the planned changes:

```bash
terraform plan
```

4. Apply the changes:

```bash
terraform apply
```

5. To destroy the resources:

```bash
terraform destroy
```

## Modules

### S3 Module

The S3 bucket is configured with:
- Versioning enabled
- Server-side encryption
- CORS configuration for web uploads
- Lifecycle rules for cost optimization

See the [S3 module README](./modules/s3/README.md) for more details.

## Environment Configurations

### Development

The development environment is configured for:
- Maximum flexibility for testing
- Permissive CORS settings
- Less aggressive lifecycle rules

### Production

The production environment is configured for:
- Strict security settings
- Optimized cost management
- Performance and reliability

## Standards

This infrastructure code follows the [terraform_standards.mdc](../.cursor/rules/terraform_standards.mdc) rules:
- Consistent naming conventions
- Standard tagging
- Modular approach
- Security best practices

## Next Steps

Future infrastructure components to be added:
1. EventBridge integration
2. Step Functions workflow
3. Lambda processing functions
4. Vector database configuration 