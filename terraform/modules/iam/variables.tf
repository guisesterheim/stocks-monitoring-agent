variable "role_name" {
  type        = string
  description = "Base name for the IAM roles created for AgentCore Runtime"
}

variable "stocks_table_arn" {
  type        = string
  description = "ARN of the DynamoDB stocks list table"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic for stock alert notifications"
}
