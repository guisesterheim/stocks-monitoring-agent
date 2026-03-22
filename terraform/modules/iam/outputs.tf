output "agentcore_runtime_role_arn" {
  description = "ARN of the AgentCore Runtime IAM role"
  value       = aws_iam_role.agentcore_runtime_role.arn
}

output "agentcore_memory_role_arn" {
  description = "ARN of the AgentCore Memory IAM role"
  value       = aws_iam_role.agentcore_memory_role.arn
}
