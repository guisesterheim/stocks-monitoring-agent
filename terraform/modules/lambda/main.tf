resource "aws_ecr_repository" "lambda_invoker_repository" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "lambda_invoker_lifecycle" {
  repository = aws_ecr_repository.lambda_invoker_repository.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = { type = "expire" }
    }]
  })
}

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
  timeout       = 30

  environment {
    variables = {
      AGENTCORE_RUNTIME_ARN = var.agentcore_runtime_arn
    }
  }
}
