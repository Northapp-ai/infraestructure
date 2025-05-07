variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "qa"
}

variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default = {
    Environment = "qa"
    Project     = "north"
    ManagedBy   = "terraform"
  }
} 