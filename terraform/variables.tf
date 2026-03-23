variable "ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository for the agent container image"
}

variable "monitored_tickers" {
  type        = list(string)
  description = "List of ticker symbols to seed into the monitored stocks DynamoDB table"
  default     = []
}

variable "stocks_table_name" {
  type        = string
  description = "Name of the DynamoDB table storing the monitored stocks list"
}

variable "sns_topic_name" {
  type        = string
  description = "Name of the SNS topic for stock alert notifications"
}

variable "recipient_email_addresses" {
  type        = list(string)
  description = "List of email addresses to receive stock alert notifications"
}

variable "ses_sender_email_address" {
  type        = string
  description = "Sender email address already verified in SES. Leave empty to use SNS only."
  default     = ""
}

variable "iam_role_name" {
  type        = string
  description = "Name of the IAM role for the AgentCore Runtime"
}

variable "agentcore_runtime_name" {
  type        = string
  description = "Name of the AgentCore Runtime"
}

variable "container_image_uri" {
  type        = string
  description = "Full URI of the agent container image in ECR (including tag)"
}

variable "daily_drop_threshold_percent" {
  type        = number
  description = "Percentage drop in a single day that triggers a notification"
  default     = 2
}

variable "weekly_drop_threshold_percent" {
  type        = number
  description = "Percentage drop over 5 trading days that triggers a notification"
  default     = 5
}

variable "claude_model_id" {
  type        = string
  description = "Bedrock model ID for Claude to use in the agent"
}

variable "lambda_invoker_ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository for the Lambda invoker container image"
}

variable "lambda_invoker_role_name" {
  type        = string
  description = "Name of the IAM role for the Lambda invoker function"
}

variable "lambda_invoker_function_name" {
  type        = string
  description = "Name of the Lambda invoker function"
}

variable "lambda_invoker_image_uri" {
  type        = string
  description = "Full URI of the Lambda invoker container image in ECR (including tag)"
}

variable "eventbridge_schedule_name" {
  type        = string
  description = "Name of the EventBridge Scheduler schedule"
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Name of the CloudWatch log group the agent writes diagnostic logs to"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in all CloudWatch log groups"
  default     = 7
}

variable "existing_log_group_names" {
  type        = list(string)
  description = "List of existing CloudWatch log group names to manage retention on (e.g. Lambda log groups)"
  default     = []
}
