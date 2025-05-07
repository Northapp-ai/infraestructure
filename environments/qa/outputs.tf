output "api_gateway_url" {
  description = "URL del API Gateway"
  value       = module.api_gateway.api_url
}

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "ID del Client de Cognito"
  value       = module.cognito.client_id
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3"
  value       = module.s3_uploads.bucket_name
}

output "lambda_functions" {
  description = "ARNs de las funciones Lambda"
  value       = module.lambda_functions.lambda_arns
} 