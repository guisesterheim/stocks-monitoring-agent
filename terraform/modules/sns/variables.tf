variable "topic_name" {
  type        = string
  description = "Name of the SNS topic for stock alert notifications"
}

variable "recipient_email_addresses" {
  type        = list(string)
  description = "List of email addresses to subscribe to the SNS topic"
}
