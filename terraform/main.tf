data "aws_caller_identity" "current" {}

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
  monitored_tickers = var.monitored_tickers
}

module "sns" {
  source                    = "./modules/sns"
  topic_name                = var.sns_topic_name
  recipient_email_addresses = var.recipient_email_addresses
}

module "iam" {
  source                          = "./modules/iam"
  role_name                       = var.iam_role_name
  stocks_table_arn                = module.dynamodb.stocks_table_arn
  sns_topic_arn                   = module.sns.topic_arn
  aws_account_id                  = data.aws_caller_identity.current.account_id
}

module "security_group" {
  source              = "./modules/security_group"
  security_group_name = var.agentcore_security_group_name
  vpc_id              = var.vpc_id
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
  subnet_ids                     = var.agentcore_subnet_ids
  security_group_ids             = [module.security_group.security_group_id]
  stock_quote_url_template       = var.stock_quote_url_template
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