output "user_pool_id" {
  description = "ID del Cognito User Pool para el entorno dev"
  value       = module.cognito.user_pool_id
}

output "client_id" {
  description = "ID del Cognito User Pool Client para el entorno dev"
  value       = module.cognito.client_id
}

output "api_url" {
  description = "API Gateway endpoint"
  value       = module.api_gateway.api_endpoint
}

output "lambda_names" {
  value = module.lambda_functions.function_names
}

output "dynamodb_table_names" {
  value = module.dynamodb_tables.table_names
}


output "lambda_exec_role_arn" {
  value = module.lambda_functions.lambda_exec_role_arn
} 