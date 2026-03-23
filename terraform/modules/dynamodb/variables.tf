variable "stocks_table_name" {
  type        = string
  description = "Name of the DynamoDB table storing the list of monitored stocks"
}

variable "monitored_tickers" {
  type        = list(string)
  description = "List of ticker symbols to seed into the monitored stocks table"
  default     = []
}
