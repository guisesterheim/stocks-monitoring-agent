variable "schedule_name" {
  type        = string
  description = "Name of the EventBridge Scheduler schedule"
}

variable "agentcore_runtime_arn" {
  type        = string
  description = "ARN of the AgentCore Runtime to invoke on schedule"
}
