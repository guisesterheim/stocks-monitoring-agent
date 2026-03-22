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
    CLAUDE_API_KEY_SECRET_NAME    = var.claude_api_key_secret_name
    STOCKS_TABLE_NAME             = var.stocks_table_name
    PRICES_TABLE_NAME             = var.prices_table_name
    AGENTCORE_MEMORY_ID           = var.agentcore_memory_id
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
