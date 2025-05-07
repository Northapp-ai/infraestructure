variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "cors_allowed_origins" {
  description = "Orígenes permitidos para CORS"
  type        = list(string)
  default     = ["*"] # cámbialo a tu frontend si lo sabes
}
