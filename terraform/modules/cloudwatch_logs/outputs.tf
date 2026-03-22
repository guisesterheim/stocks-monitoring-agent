output "agentcore_runtime_log_group_arn" {
  description = "ARN of the CloudWatch log group for the AgentCore Runtime"
  value       = aws_cloudwatch_log_group.agentcore_runtime.arn
}
