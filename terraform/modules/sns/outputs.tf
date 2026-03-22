output "topic_arn" {
  description = "ARN of the SNS stock alerts topic"
  value       = aws_sns_topic.stock_alerts.arn
}
