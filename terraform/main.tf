module "ecr" {
  source = "./modules/ecr"
  repository_names = {
    agent          = var.ecr_repository_name
    lambda_invoker = var.lambda_invoker_ecr_repository_name
  }
}

module "dynamodb" {
  source            = "./modules/dynamodb"
  stocks_table_name = var.stocks_table_name
}

module "sns" {
  source                    = "./modules/sns"
  topic_name                = var.sns_topic_name
  recipient_email_addresses = var.recipient_email_addresses
}

module "cloudwatch_logs" {
  source                   = "./modules/cloudwatch_logs"
  agentcore_runtime_name   = var.agentcore_runtime_name
  log_retention_days       = var.log_retention_days
  existing_log_group_names = var.existing_log_group_names
}

module "iam" {
  source           = "./modules/iam"
  role_name        = var.iam_role_name
  stocks_table_arn = module.dynamodb.stocks_table_arn
  sns_topic_arn    = module.sns.topic_arn
}

module "agentcore_runtime" {
  source                         = "./modules/agentcore_runtime"
  runtime_name                   = var.agentcore_runtime_name
  runtime_role_arn               = module.iam.agentcore_runtime_role_arn
  container_image_uri            = var.container_image_uri
  stocks_table_name              = module.dynamodb.stocks_table_name
  sns_topic_arn                  = module.sns.topic_arn
  sender_email_address           = var.ses_sender_email_address
  recipient_email_addresses_json = jsonencode(var.recipient_email_addresses)
  daily_drop_threshold_percent   = var.daily_drop_threshold_percent
  weekly_drop_threshold_percent  = var.weekly_drop_threshold_percent
  claude_model_id                = var.claude_model_id
  log_group_name                 = module.cloudwatch_logs.agentcore_runtime_log_group_arn
}

module "lambda" {
  source                = "./modules/lambda"
  lambda_role_name      = var.lambda_invoker_role_name
  function_name         = var.lambda_invoker_function_name
  container_image_uri   = var.lambda_invoker_image_uri
  agentcore_runtime_arn = module.agentcore_runtime.runtime_arn
}

module "eventbridge" {
  source              = "./modules/eventbridge"
  schedule_name       = var.eventbridge_schedule_name
  lambda_function_arn = module.lambda.function_arn
}
