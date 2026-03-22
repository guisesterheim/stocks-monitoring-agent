variable "schedule_name" {
  type        = string
  description = "Name of the EventBridge Scheduler schedule"
}

variable "lambda_function_arn" {
  type        = string
  description = "ARN of the Lambda invoker function to trigger on schedule"
}
