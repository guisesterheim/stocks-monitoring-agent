variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "lambda_execution_role_arn" {
  type        = string
  description = "ARN of the IAM role the Lambda function will assume"
}

variable "lambda_zip_path" {
  type        = string
  description = "Local path to the zipped Lambda deployment package"
}

variable "claude_api_key_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret containing the Claude API key"
}

variable "lambda_timeout_seconds" {
  type        = number
  description = "Lambda function timeout in seconds"
}

variable "lambda_memory_mb" {
  type        = number
  description = "Lambda function memory allocation in MB"
}
