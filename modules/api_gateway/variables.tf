variable "routes" {
  description = "Lista de rutas que integran Lambdas en el API Gateway"
  type = list(object({
    path         = string  # Ej: "/lambda1"
    method       = string  # Ej: "GET"
    lambda_arn   = string
    lambda_name  = string
  }))
}
