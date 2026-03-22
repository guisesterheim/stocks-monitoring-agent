output "memory_arn" {
  description = "ARN of the AgentCore Memory resource"
  value       = awscc_bedrockagentcore_memory.stock_prices_memory.memory_arn
}

output "memory_id" {
  description = "ID of the AgentCore Memory resource"
  value       = awscc_bedrockagentcore_memory.stock_prices_memory.memory_id
}
