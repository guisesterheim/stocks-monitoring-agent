variable "lambda_role_name" {
  type        = string
  description = "Name of the IAM role for the Lambda invoker function"
}

variable "function_name" {
  type        = string
  description = "Name of the Lambda invoker function"
}

variable "container_image_uri" {
  type        = string
  description = "Full URI of the Lambda invoker container image in ECR (including tag)"
}

variable "agentcore_runtime_arn" {
  type        = string
  description = "ARN of the AgentCore Runtime to invoke"
}
