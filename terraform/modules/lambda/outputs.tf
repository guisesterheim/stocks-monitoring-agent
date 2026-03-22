output "function_arn" {
  description = "ARN of the Lambda invoker function"
  value       = aws_lambda_function.invoker.arn
}
