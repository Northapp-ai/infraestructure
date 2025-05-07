# modelues/cognito/variables.tf

variable "user_pool_name" {}
variable "client_name" {}

variable "lambda_exec_role_arn" {
  type        = string
  description = "ARN del rol que usarán las lambdas"
}
