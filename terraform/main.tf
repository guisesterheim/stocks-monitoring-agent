module "secrets_manager" {
  source = "./modules/secrets_manager"

  claude_api_key_secret_name = var.claude_api_key_secret_name
}

module "lambda" {
  source = "./modules/lambda"

  function_name              = var.lambda_function_name
  lambda_zip_path            = var.lambda_zip_path
  claude_api_key_secret_arn  = module.secrets_manager.claude_api_key_secret_arn
  claude_api_key_secret_name = var.claude_api_key_secret_name
  aws_region                 = "us-east-1"
  lambda_timeout_seconds     = var.lambda_timeout_seconds
  lambda_memory_mb           = var.lambda_memory_mb
}
