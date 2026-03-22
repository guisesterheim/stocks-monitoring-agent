variable "function_name" {
  type        = string
  description = "Name of the Lambda function, used to name the IAM role and policy"
}

variable "claude_api_key_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret the Lambda role needs access to"
}
