output "managed_log_group_names" {
  description = "Names of the CloudWatch log groups with managed retention"
  value       = [for lg in aws_cloudwatch_log_group.existing : lg.name]
}
