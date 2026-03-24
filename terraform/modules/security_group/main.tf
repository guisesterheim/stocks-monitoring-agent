resource "aws_security_group" "agentcore_runtime" {
  name        = var.security_group_name
  description = "Security group for AgentCore Runtime allows outbound HTTPS to AWS services only"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow outbound HTTPS to AWS services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}
