variable "repository_names" {
  type        = map(string)
  description = "Map of logical key to ECR repository name (e.g. { agent = \"my-agent\", lambda_invoker = \"my-invoker\" })"
}
