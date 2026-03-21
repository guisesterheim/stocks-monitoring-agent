variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "lambda_zip_path" {
  type        = string
  description = "Local path to the zipped Lambda deployment package"
}

variable "claude_api_key_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret containing the Claude API key"
}

variable "claude_api_key_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret containing the Claude API key"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the Lambda function is deployed"
}

variable "lambda_timeout_seconds" {
  type        = number
  description = "Lambda function timeout in seconds"
}

variable "lambda_memory_mb" {
  type        = number
  description = "Lambda function memory allocation in MB"
}
