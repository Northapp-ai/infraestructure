output "main_vpc_id" {
  description = "ID of the main VPC network"
  value       = module.vpc.vpc_id
}

output "api_gateway_endpoint_url" {
  description = "Public URL endpoint for the API Gateway"
  value       = module.api_gateway.api_url
}

output "cognito_user_pool_identifier" {
  description = "Unique identifier for the Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "cognito_app_client_identifier" {
  description = "Unique identifier for the Cognito App Client"
  value       = module.cognito.client_id
  sensitive   = true
}

output "lambda_function_arns" {
  description = "Map of Lambda function names to their ARNs"
  value       = module.lambda_functions.function_arns
}

output "dynamodb_table_arns" {
  description = "Map of DynamoDB table names to their ARNs"
  value       = module.dynamodb_tables.table_arns
}

output "main_s3_bucket_name" {
  description = "Name of the main S3 bucket for application storage"
  value       = module.s3_bucket.bucket_name
} 