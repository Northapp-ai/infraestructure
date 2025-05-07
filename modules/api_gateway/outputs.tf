output "api_endpoint" {
  description = "Base URL del API Gateway"
  value       = aws_apigatewayv2_api.this.api_endpoint
}
