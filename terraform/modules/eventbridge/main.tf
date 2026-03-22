resource "aws_scheduler_schedule" "daily_stock_monitor_trigger" {
  name       = var.schedule_name
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # 3:30 PM EST = 20:30 UTC
  schedule_expression          = "cron(30 20 * * ? *)"
  schedule_expression_timezone = "America/New_York"

  target {
    arn      = var.agentcore_runtime_arn
    role_arn = aws_iam_role.scheduler_role.arn

    input = jsonencode({
      trigger = "scheduled_daily_run"
    })
  }
}

resource "aws_iam_role" "scheduler_role" {
  name = "${var.schedule_name}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "scheduler_invoke_policy" {
  name = "${var.schedule_name}-invoke-policy"
  role = aws_iam_role.scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock-agentcore:InvokeAgentRuntime"]
      Resource = [var.agentcore_runtime_arn]
    }]
  })
}
