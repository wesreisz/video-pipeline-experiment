resource "aws_lambda_function" "function" {
  function_name    = var.function_name
  description      = var.description
  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  role             = aws_iam_role.lambda_execution_role.arn

  environment {
    variables = length(var.environment_variables) > 0 ? var.environment_variables : { DUMMY_VAR = "dummy_value" }
  }

  tags = merge(
    {
      Name        = var.function_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "Compute"
      Project     = "VideoPipeline"
    },
    var.tags
  )
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.function_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.function_name}-execution-role"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "IAM"
      Project     = "VideoPipeline"
    },
    var.tags
  )
}

# Basic Lambda execution policy attachment
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 read access policy for Lambda
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "${var.function_name}-s3-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:CopyObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = var.s3_bucket_arns
      }
    ]
  })
}

# Transcribe access policy for Lambda
resource "aws_iam_role_policy" "lambda_transcribe_policy" {
  name   = "${var.function_name}-transcribe-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "transcribe:StartTranscriptionJob",
          "transcribe:GetTranscriptionJob",
          "transcribe:ListTranscriptionJobs"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = concat(var.s3_bucket_arns, ["${var.s3_bucket_arns[0]}/transcripts/*"])
      },
      {
        Action = [
          "events:PutRule",
          "events:PutTargets",
          "events:DescribeRule",
          "events:ListRules"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Lambda permission for S3 bucket to invoke function
resource "aws_lambda_permission" "allow_s3_bucket" {
  count         = length(var.s3_bucket_arns) > 0 ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_trigger_arn
}

# EventBridge rule for Transcribe job completion
resource "aws_cloudwatch_event_rule" "transcribe_job_state_change" {
  name        = "${var.function_name}-transcribe-job-completion"
  description = "Capture Transcribe job completion events"
  
  event_pattern = jsonencode({
    source      = ["aws.transcribe"],
    "detail-type" = ["Transcribe Job State Change"],
    detail = {
      TranscriptionJobStatus = ["COMPLETED", "FAILED"]
    }
  })
}

# Target the Lambda function with the EventBridge rule
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.transcribe_job_state_change.name
  target_id = "${var.function_name}-target"
  arn       = aws_lambda_function.function.arn
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.transcribe_job_state_change.arn
} 