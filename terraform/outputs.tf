output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function"
  value       = module.lambda.lambda_function_arn
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = module.lambda.lambda_function_name
}

output "claude_api_key_secret_arn" {
  description = "ARN of the Claude API key secret in Secrets Manager"
  value       = module.secrets_manager.claude_api_key_secret_arn
}
