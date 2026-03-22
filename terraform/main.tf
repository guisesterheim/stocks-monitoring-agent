module "secrets_manager" {
  source                     = "./modules/secrets_manager"
  claude_api_key_secret_name = var.claude_api_key_secret_name
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
}

module "dynamodb" {
  source            = "./modules/dynamodb"
  stocks_table_name = var.stocks_table_name
  prices_table_name = var.prices_table_name
}

module "sns" {
  source                    = "./modules/sns"
  topic_name                = var.sns_topic_name
  recipient_email_addresses = var.recipient_email_addresses
}

module "agentcore_memory" {
  source                    = "./modules/agentcore_memory"
  memory_name               = var.agentcore_memory_name
  memory_event_expiry_days  = var.memory_event_expiry_days
  memory_execution_role_arn = module.iam.agentcore_memory_role_arn
}

module "iam" {
  source                    = "./modules/iam"
  role_name                 = var.iam_role_name
  claude_api_key_secret_arn = module.secrets_manager.claude_api_key_secret_arn
  stocks_table_arn          = module.dynamodb.stocks_table_arn
  prices_table_arn          = module.dynamodb.prices_table_arn
  sns_topic_arn             = module.sns.topic_arn
  agentcore_memory_arn      = module.agentcore_memory.memory_arn
}

module "agentcore_runtime" {
  source                         = "./modules/agentcore_runtime"
  runtime_name                   = var.agentcore_runtime_name
  runtime_role_arn               = module.iam.agentcore_runtime_role_arn
  container_image_uri            = var.container_image_uri
  claude_api_key_secret_name     = module.secrets_manager.claude_api_key_secret_name
  stocks_table_name              = module.dynamodb.stocks_table_name
  prices_table_name              = module.dynamodb.prices_table_name
  agentcore_memory_id            = module.agentcore_memory.memory_id
  sns_topic_arn                  = module.sns.topic_arn
  sender_email_address           = var.ses_sender_email_address
  recipient_email_addresses_json = jsonencode(var.recipient_email_addresses)
  daily_drop_threshold_percent   = var.daily_drop_threshold_percent
  weekly_drop_threshold_percent  = var.weekly_drop_threshold_percent
  claude_model_id                = var.claude_model_id
}

module "eventbridge" {
  source                = "./modules/eventbridge"
  schedule_name         = var.eventbridge_schedule_name
  agentcore_runtime_arn = module.agentcore_runtime.runtime_arn
}
