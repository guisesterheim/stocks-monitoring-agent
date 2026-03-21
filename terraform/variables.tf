variable "terraform_state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket used for Terraform remote state"
}

variable "claude_api_key_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret for the Claude API key"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
  default     = "stocks-monitor-agent"
}

variable "lambda_zip_path" {
  type        = string
  description = "Path to the zipped Lambda deployment package"
  default     = "../lambda.zip"
}

variable "lambda_timeout_seconds" {
  type        = number
  description = "Lambda function timeout in seconds"
}

variable "lambda_memory_mb" {
  type        = number
  description = "Lambda function memory allocation in MB"
}
