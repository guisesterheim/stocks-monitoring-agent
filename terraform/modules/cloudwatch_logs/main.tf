resource "aws_cloudwatch_log_group" "agentcore_runtime" {
  name              = "/aws/bedrock-agentcore/runtimes/${var.agentcore_runtime_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "existing" {
  for_each = toset(var.existing_log_group_names)

  name              = each.value
  retention_in_days = var.log_retention_days
}
