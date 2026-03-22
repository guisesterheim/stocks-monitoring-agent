module "secrets_manager" {
  source = "./modules/secrets_manager"

  claude_api_key_secret_name = var.claude_api_key_secret_name
}

module "iam" {
  source = "./modules/iam"

  function_name             = var.lambda_function_name
  claude_api_key_secret_arn = module.secrets_manager.claude_api_key_secret_arn
}

module "lambda" {
  source = "./modules/lambda"

  function_name              = var.lambda_function_name
  lambda_execution_role_arn  = module.iam.lambda_execution_role_arn
  lambda_zip_path            = var.lambda_zip_path
  claude_api_key_secret_name = var.claude_api_key_secret_name
  lambda_timeout_seconds     = var.lambda_timeout_seconds
  lambda_memory_mb           = var.lambda_memory_mb
}
