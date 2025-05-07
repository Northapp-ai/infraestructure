# Crear el bucket S3 para el estado de Terraform
resource "aws_s3_bucket" "terraform_state" {
  bucket = "north-terraform-state-bucket"

  # Prevenir eliminación accidental
  lifecycle {
    prevent_destroy = true
  }
}

# Habilitar versionamiento para el bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Habilitar encriptación para el bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquear acceso público
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuración del backend de Terraform
terraform {
  backend "s3" {
    bucket         = "north-terraform-state-bucket"
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "north-terraform-state-lock"
    kms_key_id     = "alias/north-terraform-state-key"
    acl            = "private"
    use_path_style = true
  }
}
