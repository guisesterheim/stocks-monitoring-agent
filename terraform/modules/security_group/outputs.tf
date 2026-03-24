output "security_group_id" {
  description = "ID of the AgentCore Runtime security group"
  value       = aws_security_group.agentcore_runtime.id
}
