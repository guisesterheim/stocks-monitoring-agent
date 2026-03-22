variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in all managed log groups"
}

variable "existing_log_group_names" {
  type        = list(string)
  description = "List of existing CloudWatch log group names to manage retention on (e.g. Lambda log groups)"
  default     = []
}
