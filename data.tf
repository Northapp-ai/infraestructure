# Obtener información de la cuenta AWS actual
data "aws_caller_identity" "current" {}

# Obtener información de la región actual
data "aws_region" "current" {}

# Obtener información de la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Obtener información de las subnets disponibles
data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Obtener información de las zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

# Obtener información del KMS key para encriptación
data "aws_kms_key" "terraform_state" {
  key_id = "alias/north-terraform-state-key"
}

# Obtener información de los grupos de logs existentes
data "aws_cloudwatch_log_groups" "existing" {
  log_group_name_prefix = "/aws/lambda/${local.name_prefix}"
} 