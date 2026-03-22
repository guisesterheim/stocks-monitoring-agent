output "function_arn" {
  description = "ARN of the Lambda invoker function"
  value       = aws_lambda_function.invoker.arn
}

output "ecr_repository_url" {
  description = "URL of the Lambda invoker ECR repository"
  value       = aws_ecr_repository.lambda_invoker_repository.repository_url
}
