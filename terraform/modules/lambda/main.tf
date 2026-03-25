resource "aws_iam_role" "lambda_invoker_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_invoker_policy" {
  name = "${var.lambda_role_name}-policy"
  role = aws_iam_role.lambda_invoker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAgentCoreInvoke"
        Effect   = "Allow"
        Action   = ["bedrock-agentcore:InvokeAgentRuntime"]
        Resource = ["${var.agentcore_runtime_arn}*"]
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:us-east-1:*:*"]
      }
    ]
  })
}

resource "aws_lambda_function" "invoker" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_invoker_role.arn
  package_type  = "Image"
  image_uri     = var.container_image_uri
  architectures = ["arm64"]
  timeout       = 300

  environment {
    variables = {
      AGENTCORE_RUNTIME_ARN = var.agentcore_runtime_arn
    }
  }
}
