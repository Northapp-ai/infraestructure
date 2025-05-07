provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.resource_tags
  }

  # Ignorar tags de AWS en recursos que no las soportan
  ignore_tags {
    key_prefixes = ["aws:"]
  }
}

# Provider para recursos temporales
provider "null" {}

# Provider para generación de valores aleatorios
provider "random" {}

# Provider para manejo de archivos comprimidos
provider "archive" {}
