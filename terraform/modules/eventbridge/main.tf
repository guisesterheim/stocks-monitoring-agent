resource "aws_scheduler_schedule" "daily_stock_monitor_trigger" {
  name       = var.schedule_name
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # 3:30 PM EST — EventBridge Scheduler cron format: (minutes hours day-of-month month day-of-week year)
  schedule_expression          = "cron(30 15 ? * MON-FRI *)"
  schedule_expression_timezone = "America/New_York"

  target {
    arn      = var.lambda_function_arn
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
      Action   = ["lambda:InvokeFunction"]
      Resource = [var.lambda_function_arn]
    }]
  })
}

resource "aws_lambda_permission" "allow_scheduler" {
  statement_id  = "AllowEventBridgeScheduler"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.daily_stock_monitor_trigger.arn
}
