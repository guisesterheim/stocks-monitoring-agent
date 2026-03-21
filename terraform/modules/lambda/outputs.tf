output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.stocks_monitor_agent.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.stocks_monitor_agent.function_name
}
