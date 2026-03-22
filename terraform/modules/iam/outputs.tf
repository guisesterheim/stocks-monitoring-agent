output "agentcore_runtime_role_arn" {
  description = "ARN of the AgentCore Runtime IAM role"
  value       = aws_iam_role.agentcore_runtime_role.arn
}
