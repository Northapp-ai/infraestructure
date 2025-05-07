# Validar el ambiente de despliegue
check "deployment_environment" {
  assert {
    condition     = contains(["development", "staging", "production"], var.deployment_environment)
    error_message = "El ambiente de despliegue debe ser 'development', 'staging' o 'production'"
  }
}

# Validar el nombre del proyecto
check "project_name" {
  assert {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "El nombre del proyecto solo puede contener letras minúsculas, números y guiones"
  }
}

# Validar la región AWS
check "aws_region" {
  assert {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[1-9]$", var.aws_region))
    error_message = "La región AWS debe tener un formato válido (ej: us-east-1)"
  }
}

# Validar el bloque CIDR de la VPC
check "vpc_cidr_block" {
  assert {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "El bloque CIDR de la VPC debe ser válido"
  }
}

# Validar el período de retención de logs
check "log_retention_period" {
  assert {
    condition     = var.log_retention_period >= 1 && var.log_retention_period <= 365
    error_message = "El período de retención de logs debe estar entre 1 y 365 días"
  }
} 