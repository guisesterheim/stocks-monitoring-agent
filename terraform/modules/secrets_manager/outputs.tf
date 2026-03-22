output "claude_api_key_secret_arn" {
  description = "ARN of the Claude API key secret"
  value       = aws_secretsmanager_secret.claude_api_key.arn
}

output "claude_api_key_secret_name" {
  description = "Name of the Claude API key secret"
  value       = aws_secretsmanager_secret.claude_api_key.name
}
