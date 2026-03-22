resource "aws_cloudwatch_log_group" "existing" {
  for_each = toset(var.existing_log_group_names)

  name              = each.value
  retention_in_days = var.log_retention_days
}
