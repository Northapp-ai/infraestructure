# Limpiar objetos del bucket S3 antes de eliminarlo
resource "null_resource" "cleanup_s3_bucket" {
  triggers = {
    bucket_name = module.s3_bucket.bucket_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws s3 rm s3://${module.s3_bucket.bucket_name} --recursive
    EOT
  }

  depends_on = [module.s3_bucket]
}

# Limpiar logs de CloudWatch antes de eliminar los grupos
resource "null_resource" "cleanup_cloudwatch_logs" {
  for_each = local.log_groups

  triggers = {
    log_group_name = each.value
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws logs delete-log-group --log-group-name ${each.value}
    EOT
  }
}

# Limpiar versiones de objetos S3
resource "aws_s3_bucket_versioning" "disable_versioning" {
  bucket = module.s3_bucket.bucket_name
  versioning_configuration {
    status = "Disabled"
  }
}

# Configurar ciclo de vida para objetos S3
resource "aws_s3_bucket_lifecycle_configuration" "cleanup_old_versions" {
  bucket = module.s3_bucket.bucket_name

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
} 