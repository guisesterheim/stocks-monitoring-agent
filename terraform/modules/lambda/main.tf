resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.function_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_secrets_policy" {
  name = "${var.function_name}-secrets-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [var.claude_api_key_secret_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "stocks_monitor_agent" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = var.lambda_zip_path
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = ["arm64"]
  timeout       = var.lambda_timeout_seconds
  memory_size   = var.lambda_memory_mb

  environment {
    variables = {
      CLAUDE_API_KEY_SECRET_NAME = var.claude_api_key_secret_name
      AWS_REGION_NAME            = var.aws_region
    }
  }
}
