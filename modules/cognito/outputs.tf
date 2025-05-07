# modelues/cognito/outputs.tf

output "user_pool_id" {
  description = "ID del Cognito User Pool"
  value       = aws_cognito_user_pool.user_pool.id
}

output "client_id" {
  description = "ID del Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.client.id
}

output "post_confirmation_lambda_arn" {
  value = aws_lambda_function.cognito_post_confirmation.arn
}