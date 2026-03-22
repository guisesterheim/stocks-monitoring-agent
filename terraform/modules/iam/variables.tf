variable "role_name" {
  type        = string
  description = "Base name for the IAM roles created for AgentCore"
}

variable "claude_api_key_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret containing the Claude API key"
}

variable "stocks_table_arn" {
  type        = string
  description = "ARN of the DynamoDB stocks list table"
}

variable "prices_table_arn" {
  type        = string
  description = "ARN of the DynamoDB stock prices history table"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic for stock alert notifications"
}

variable "agentcore_memory_arn" {
  type        = string
  description = "ARN of the AgentCore Memory resource"
}
