variable "runtime_name" {
  type        = string
  description = "Name of the AgentCore Runtime"
}

variable "runtime_role_arn" {
  type        = string
  description = "ARN of the IAM role for the AgentCore Runtime"
}

variable "container_image_uri" {
  type        = string
  description = "Full URI of the container image in ECR (including tag)"
}

variable "stocks_table_name" {
  type        = string
  description = "Name of the DynamoDB table storing the monitored stocks list"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic for stock alert notifications"
}

variable "sender_email_address" {
  type        = string
  description = "Verified SES sender email address. Leave empty to use SNS only."
  default     = ""
}

variable "recipient_email_addresses_json" {
  type        = string
  description = "JSON-encoded list of recipient email addresses for SES notifications"
}

variable "daily_drop_threshold_percent" {
  type        = number
  description = "Percentage drop in a single day that triggers a notification"
}

variable "weekly_drop_threshold_percent" {
  type        = number
  description = "Percentage drop over 5 days that triggers a notification"
}

variable "claude_model_id" {
  type        = string
  description = "Bedrock model ID for Claude (e.g. amazon.nova-micro-v1:0)"
}

variable "log_group_name" {
  type        = string
  description = "Log group name to send logs to"
}
