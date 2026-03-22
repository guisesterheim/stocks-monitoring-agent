variable "stocks_table_name" {
  type        = string
  description = "Name of the DynamoDB table that stores the list of monitored stocks"
}

variable "prices_table_name" {
  type        = string
  description = "Name of the DynamoDB table that stores historical closing prices"
}
