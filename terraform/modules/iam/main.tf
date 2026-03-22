resource "aws_iam_role" "agentcore_runtime_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "agentcore_runtime_policy" {
  name = "${var.role_name}-policy"
  role = aws_iam_role.agentcore_runtime_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowSecretsManagerAccess"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [var.claude_api_key_secret_arn]
      },
      {
        Sid    = "AllowDynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = [
          var.stocks_table_arn,
          var.prices_table_arn
        ]
      },
      {
        Sid    = "AllowSESSendEmail"
        Effect = "Allow"
        Action = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = ["*"]
      },
      {
        Sid    = "AllowSNSPublish"
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = [var.sns_topic_arn]
      },
      {
        Sid    = "AllowECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ]
        Resource = ["*"]
      },
      {
        Sid    = "AllowAgentCoreMemoryAccess"
        Effect = "Allow"
        Action = [
          "bedrock-agentcore:GetMemory",
          "bedrock-agentcore:CreateMemoryEvent",
          "bedrock-agentcore:ListMemoryEvents"
        ]
        Resource = [var.agentcore_memory_arn]
      },
      {
        Sid    = "AllowAgentCoreBrowserAccess"
        Effect = "Allow"
        Action = ["bedrock-agentcore:InvokeBrowser"]
        Resource = ["*"]
      },
      {
        Sid    = "AllowBedrockModelInvocation"
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = ["*"]
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

resource "aws_iam_role" "agentcore_memory_role" {
  name = "${var.role_name}-memory"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "agentcore_memory_policy" {
  name = "${var.role_name}-memory-policy"
  role = aws_iam_role.agentcore_memory_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBedrockModelForMemory"
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = ["*"]
      }
    ]
  })
}
