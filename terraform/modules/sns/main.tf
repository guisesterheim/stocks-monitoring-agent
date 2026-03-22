resource "aws_sns_topic" "stock_alerts" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "email_subscriptions" {
  for_each  = toset(var.recipient_email_addresses)
  topic_arn = aws_sns_topic.stock_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}
