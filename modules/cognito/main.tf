resource "aws_cognito_user_pool" "user_pool" {
  name                     = var.user_pool_name
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  lambda_config {
    pre_sign_up                 = aws_lambda_function.cognito_post_confirmation.arn
    post_confirmation           = aws_lambda_function.cognito_post_confirmation.arn
    pre_authentication          = aws_lambda_function.cognito_post_confirmation.arn
    post_authentication         = aws_lambda_function.cognito_post_confirmation.arn
    custom_message              = aws_lambda_function.cognito_post_confirmation.arn
    pre_token_generation        = aws_lambda_function.cognito_post_confirmation.arn
    user_migration              = aws_lambda_function.cognito_post_confirmation.arn
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name            = var.client_name
  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = false

  callback_urls = ["http://localhost:8081", "http://localhost:3000", "https://north.com"]
  logout_urls   = ["http://localhost:8081", "http://localhost:3000", "https://north.com"]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]
}

resource "aws_lambda_function" "cognito_post_confirmation" {
  function_name = "create_user_record"
  filename      = "${path.root}/create_user_record.zip"
  handler       = "create_user_record.lambda_handler"
  runtime       = "python3.12"
  role          = var.lambda_exec_role_arn

  environment {
    variables = {
      USERS_TABLE = "Users"
    }
  }

  source_code_hash = filebase64sha256("${path.root}/create_user_record.zip")
}

resource "aws_lambda_permission" "allow_cognito_invoke" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_post_confirmation.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}