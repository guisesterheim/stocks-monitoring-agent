variable "memory_name" {
  type        = string
  description = "Name of the AgentCore Memory resource"
}

variable "memory_event_expiry_days" {
  type        = number
  description = "Number of days after which memory events expire (min 3, max 365)"
}

variable "memory_execution_role_arn" {
  type        = string
  description = "ARN of the IAM role that AgentCore Memory uses to invoke Bedrock models"
}
