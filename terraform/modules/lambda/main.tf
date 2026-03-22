resource "aws_lambda_function" "stocks_monitor_agent" {
  function_name = var.function_name
  role          = var.lambda_execution_role_arn
  filename      = var.lambda_zip_path
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = ["arm64"]
  timeout       = var.lambda_timeout_seconds
  memory_size   = var.lambda_memory_mb

  environment {
    variables = {
      CLAUDE_API_KEY_SECRET_NAME = var.claude_api_key_secret_name
      AWS_REGION_NAME            = "us-east-1"
    }
  }
}
