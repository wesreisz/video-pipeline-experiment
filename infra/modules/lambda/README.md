# Lambda Module

This module provisions an AWS Lambda function with the necessary IAM roles and permissions.

## Features

- Creates a Lambda function with configurable runtime settings
- Sets up an IAM execution role with appropriate permissions
- Configures S3 bucket triggers
- Handles Lambda environment variables
- Applies standard tagging

## Usage

```hcl
module "my_lambda" {
  source = "../../modules/lambda"

  function_name    = "my-function"
  description      = "This function does something awesome"
  filename         = "/path/to/deployment/package.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  
  environment_variables = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
  }
  
  s3_bucket_arns = [
    "arn:aws:s3:::my-bucket",
    "arn:aws:s3:::my-bucket/*"
  ]
  
  s3_trigger_arn = "arn:aws:s3:::my-bucket"
  
  environment = "dev"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| function_name | Name of the Lambda function | string | - | yes |
| description | Description of the Lambda function | string | "" | no |
| filename | Path to the Lambda deployment package | string | - | yes |
| handler | Function entrypoint in the format of file.function | string | - | yes |
| runtime | Lambda runtime to use | string | "python3.9" | no |
| timeout | Function execution timeout in seconds | number | 30 | no |
| memory_size | Amount of memory in MB for the function | number | 128 | no |
| environment_variables | Environment variables for the Lambda function | map(string) | {} | no |
| tags | Additional tags for the Lambda function | map(string) | {} | no |
| environment | Deployment environment (dev or prod) | string | "dev" | no |
| s3_bucket_arns | List of S3 bucket ARNs that the Lambda function will have access to | list(string) | [] | no |
| s3_trigger_arn | ARN of the S3 bucket that will trigger the Lambda function | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda_function_name | Name of the Lambda function |
| lambda_function_arn | ARN of the Lambda function |
| lambda_function_invoke_arn | Invoke ARN of the Lambda function |
| lambda_execution_role_arn | ARN of the Lambda execution role |
| lambda_execution_role_name | Name of the Lambda execution role | 