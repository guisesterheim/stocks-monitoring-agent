variable "security_group_name" {
  type        = string
  description = "Name of the security group for the AgentCore Runtime"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the security group will be created"
}
