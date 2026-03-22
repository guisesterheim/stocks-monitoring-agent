resource "awscc_bedrockagentcore_runtime" "stocks_monitor_runtime" {
  agent_runtime_name = var.runtime_name
  description        = "AgentCore Runtime for the stocks monitor agent"
  role_arn           = var.runtime_role_arn

  agent_runtime_artifact = {
    container_configuration = {
      container_uri = var.container_image_uri
    }
  }

  network_configuration = {
    network_mode = "PUBLIC"
  }

  protocol_configuration = "HTTP"

  environment_variables = {
    STOCKS_TABLE_NAME             = var.stocks_table_name
    SNS_TOPIC_ARN                 = var.sns_topic_arn
    SENDER_EMAIL_ADDRESS          = var.sender_email_address
    RECIPIENT_EMAIL_ADDRESSES     = var.recipient_email_addresses_json
    DAILY_DROP_THRESHOLD_PERCENT  = tostring(var.daily_drop_threshold_percent)
    WEEKLY_DROP_THRESHOLD_PERCENT = tostring(var.weekly_drop_threshold_percent)
    CLAUDE_MODEL_ID               = var.claude_model_id
    AWS_REGION_NAME               = "us-east-1"
    USE_SES                       = var.sender_email_address != "" ? "true" : "false"
  }
}

resource "aws_cloudwatch_log_delivery_destination" "application" {
  name          = "agentcore-application-log-destination"
  output_format = "json" # Can also be "plaintext" or "clf"

  delivery_destination_configuration {
    destination_resource_arn = var.log_group_name
  }
}

resource "aws_cloudwatch_log_delivery_source" "application_source" {
  name     = "agentcore-application-log-source"
  log_type = "APPLICATION_LOGS"
  # Replace with the actual ARN of your agent runtime resource
  resource_arn = awscc_bedrockagentcore_runtime.stocks_monitor_runtime.agent_runtime_arn
}

resource "aws_cloudwatch_log_delivery" "application_delivery" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.application_source.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.application.arn
}
