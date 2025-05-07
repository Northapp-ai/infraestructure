output "lambda_arns" {
  description = "ARNs de las Lambdas creadas"
  value = { for name, func in aws_lambda_function.this : name => func.arn }
}

output "function_names" {
  description = "Nombres de las funciones Lambda"
  value       = keys(aws_lambda_function.this)
}

output "lambda_exec_role_arn" {
  description = "ARN del rol IAM que utilizan las Lambdas"
  value       = aws_iam_role.lambda_exec.arn
}
