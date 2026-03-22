output "stocks_table_name" {
  description = "Name of the stocks list DynamoDB table"
  value       = aws_dynamodb_table.stocks_list.name
}

output "stocks_table_arn" {
  description = "ARN of the stocks list DynamoDB table"
  value       = aws_dynamodb_table.stocks_list.arn
}

output "prices_table_name" {
  description = "Name of the stock prices history DynamoDB table"
  value       = aws_dynamodb_table.stock_prices_history.name
}

output "prices_table_arn" {
  description = "ARN of the stock prices history DynamoDB table"
  value       = aws_dynamodb_table.stock_prices_history.arn
}
