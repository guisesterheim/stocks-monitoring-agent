resource "aws_secretsmanager_secret" "claude_api_key" {
  name        = var.claude_api_key_secret_name
  description = "Claude API key for the stocks monitor agent"
}

resource "aws_secretsmanager_secret_version" "claude_api_key_initial" {
  secret_id     = aws_secretsmanager_secret.claude_api_key.id
  secret_string = "{}"

  lifecycle {
    ignore_changes = [secret_string]
  }
}
