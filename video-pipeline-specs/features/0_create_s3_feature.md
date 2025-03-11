# Prompt: Create an S3 Bucket using Terraform

## Objective
Create an AWS S3 bucket using Terraform following the Video Pipeline project's standards.

## Instructions

1. **Create a directory structure for a Terraform project:**
   - Organize resources in the "infra" directory
   - Create a modules directory with an S3 module
   - Create an environments directory with a dev environment
   - Use the proper file organization: main.tf, variables.tf, outputs.tf in each directory

2. **Generate Terraform code for an S3 module that:**
   - Uses snake_case for resource naming (e.g., video_pipeline_input)
   - Creates an S3 bucket with a random suffix
   - Enables versioning
   - Configures server-side encryption
   - Sets up CORS for web access
   - Implements lifecycle policies to transition objects to STANDARD_IA and GLACIER
   - Implements our standard tagging strategy with Environment, Project, ManagedBy, Component tags
   - Outputs important values like bucket name, ARN, and domain name
   - Includes a README.md with documentation

3. **Create a dev environment that:**
   - Uses the S3 module
   - Has proper variables with sensible defaults and follows our variable definition standards
   - Includes descriptions, types, and default values for all variables
   - Outputs the module outputs
   - Uses version pinning for AWS provider to patch level (~> 4.16.0)
   - Sets required Terraform version to >= 1.2.0

4. **Deployment and verification steps:**
   - Running terraform fmt for proper code formatting
   - Running terraform validate to check for errors
   - Initializing the Terraform environment
   - Running a plan to preview changes
   - Applying the configuration to create the resources
   - Verifying the deployment

## Expected Outcome
- A properly structured Terraform project with modules and environments
- A reusable S3 module with all required features
- A dev environment configuration that uses the module
- A successfully deployed and verified S3 bucket with proper configuration