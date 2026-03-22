output "runtime_arn" {
  description = "ARN of the AgentCore Runtime"
  value       = awscc_bedrockagentcore_runtime.stocks_monitor_runtime.agent_runtime_arn
}

output "runtime_id" {
  description = "ID of the AgentCore Runtime"
  value       = awscc_bedrockagentcore_runtime.stocks_monitor_runtime.agent_runtime_id
}
