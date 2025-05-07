locals {
  # Nombres de recursos
  name_prefix = "${var.project_name}-${var.deployment_environment}"
  
  # Configuración de red
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Configuración de seguridad
  security_groups = {
    api_gateway = {
      name        = "${local.name_prefix}-api-gateway-sg"
      description = "Security group for API Gateway"
    }
    lambda = {
      name        = "${local.name_prefix}-lambda-sg"
      description = "Security group for Lambda functions"
    }
  }
  
  # Configuración de logs
  log_groups = {
    api_gateway = "/aws/apigateway/${local.name_prefix}"
    lambda     = "/aws/lambda/${local.name_prefix}"
  }
  
  # Configuración de IAM
  iam_roles = {
    lambda_execution = "${local.name_prefix}-lambda-execution-role"
    api_gateway      = "${local.name_prefix}-api-gateway-role"
  }
  
  # Configuración de recursos
  resource_config = {
    lambda = {
      timeout     = 30
      memory_size = 256
    }
    dynamodb = {
      read_capacity  = 5
      write_capacity = 5
    }
  }
} 