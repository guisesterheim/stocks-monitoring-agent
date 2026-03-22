output "ecr_repository_url" {
  description = "ECR repository URL to push the agent container image to"
  value       = module.ecr.repository_urls["agent"]
}

output "lambda_invoker_ecr_repository_url" {
  description = "ECR repository URL to push the Lambda invoker container image to"
  value       = module.ecr.repository_urls["lambda_invoker"]
}

output "agentcore_runtime_arn" {
  description = "ARN of the deployed AgentCore Runtime"
  value       = module.agentcore_runtime.runtime_arn
}

output "stocks_table_name" {
  description = "Name of the DynamoDB stocks list table"
  value       = module.dynamodb.stocks_table_name
}
