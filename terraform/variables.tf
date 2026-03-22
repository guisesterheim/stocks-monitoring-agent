variable "terraform_state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket used for Terraform remote state"
}

variable "claude_api_key_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret for the Claude API key"
}

variable "ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository for the agent container image"
}

variable "stocks_table_name" {
  type        = string
  description = "Name of the DynamoDB table storing the monitored stocks list"
}

variable "prices_table_name" {
  type        = string
  description = "Name of the DynamoDB table storing historical closing prices"
}

variable "sns_topic_name" {
  type        = string
  description = "Name of the SNS topic for stock alert notifications"
}

variable "recipient_email_addresses" {
  type        = list(string)
  description = "List of email addresses to receive stock alert notifications"
}

variable "ses_domain_name" {
  type        = string
  description = "Domain name already verified in SES (managed by another repo). Leave empty to use SNS only."
  default     = ""
}

variable "ses_sender_email_address" {
  type        = string
  description = "Sender email address already verified in SES. Leave empty to use SNS only."
  default     = ""
}

variable "agentcore_memory_name" {
  type        = string
  description = "Name of the AgentCore Memory resource"
}

variable "memory_event_expiry_days" {
  type        = number
  description = "Number of days after which AgentCore Memory events expire (min 3, max 365)"
  default     = 10
}

variable "iam_role_name" {
  type        = string
  description = "Base name for the IAM roles created for AgentCore"
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

variable "eventbridge_schedule_name" {
  type        = string
  description = "Name of the EventBridge Scheduler schedule"
}
