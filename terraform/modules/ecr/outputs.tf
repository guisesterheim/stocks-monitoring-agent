output "repository_urls" {
  description = "Map of logical key to ECR repository URL"
  value       = { for k, repo in aws_ecr_repository.repositories : k => repo.repository_url }
}
