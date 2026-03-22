output "ecr_repository_url" {
  description = "ECR repository URL to push the agent container image to"
  value       = module.ecr.repository_url
}

output "agentcore_runtime_arn" {
  description = "ARN of the deployed AgentCore Runtime"
  value       = module.agentcore_runtime.runtime_arn
}

output "agentcore_memory_id" {
  description = "ID of the AgentCore Memory resource"
  value       = module.agentcore_memory.memory_id
}

output "claude_api_key_secret_arn" {
  description = "ARN of the Claude API key secret in Secrets Manager"
  value       = module.secrets_manager.claude_api_key_secret_arn
}

output "stocks_table_name" {
  description = "Name of the DynamoDB stocks list table"
  value       = module.dynamodb.stocks_table_name
}

output "prices_table_name" {
  description = "Name of the DynamoDB stock prices history table"
  value       = module.dynamodb.prices_table_name
}
