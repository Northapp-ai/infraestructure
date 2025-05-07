terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "lambda_functions" {
  source = "../../modules/lambda_functions"

  lambdas = [
    {
      name     = "dev-lambda1"
      filename = "${path.module}/lambda1.zip"
      handler  = "lambda1.handler"
      runtime  = "python3.12"
    },
    {
      name     = "dev-lambda2"
      filename = "${path.module}/lambda2.zip"
      handler  = "lambda2.handler"
      runtime  = "python3.12"
    },
    {
      name     = "generate_upload_url"
      filename = "${path.module}/generate_upload_url.zip"
      handler  = "generate_upload_url.handler"
      runtime  = "python3.12"
      environment = {
        BUCKET_NAME = "north-dev-uploads"
      }
    },
    {
      name     = "validate_data"
      filename = "${path.module}/lambda4.zip"
      handler  = "lambda4.lambda_handler"
      runtime  = "python3.12"
    }
  ]
}

module "cognito" {
  source               = "../../modules/cognito"
  user_pool_name       = "dev-user-pool"
  client_name          = "dev-client"
  lambda_exec_role_arn = module.lambda_functions.lambda_exec_role_arn
}

module "dynamodb_tables" {
  source      = "../../modules/dynamodb_tables"
  environment = "dev"

  tables = [
    {
      name     = "Users"
      hash_key = "user_id"
    },
    {
      name      = "Goals"
      hash_key  = "user_id"
      sort_key  = "GOAL#goal_id"
    },
    {
      name      = "Actions"
      hash_key  = "goal_id"
      sort_key  = "ACTION#action_id"
    },
    {
      name      = "Agenda"
      hash_key  = "user_id"
      sort_key  = "DATE#yyyy-mm-dd#action_id"
    },
    {
      name     = "SharedEntities"
      hash_key = "shared_id"
    },
    {
      name      = "Interactions"
      hash_key  = "goal_id"
      sort_key  = "INTERACTION#user_id#timestamp"
    },
    {
      name      = "Feed"
      hash_key  = "user_id"
      sort_key  = "FEED#timestamp"
    },
    {
      name      = "SearchIndex"
      hash_key  = "search_term"
      sort_key  = "TYPE#entity_id"
    }
  ]
}

module "api_gateway" {
  source = "../../modules/api_gateway"

  routes = [
    {
      path         = "/lambda1"
      method       = "GET"
      lambda_arn   = module.lambda_functions.lambda_arns["dev-lambda1"]
      lambda_name  = "dev-lambda1"
    },
    {
      path         = "/lambda2"
      method       = "GET"
      lambda_arn   = module.lambda_functions.lambda_arns["dev-lambda2"]
      lambda_name  = "dev-lambda2"
    },
    {
      path         = "/upload-url"
      method       = "GET"
      lambda_arn   = module.lambda_functions.lambda_arns["generate_upload_url"]
      lambda_name  = "generate_upload_url"
    },
    {
      path         = "/validate"
      method       = "POST"
      lambda_arn   = module.lambda_functions.lambda_arns["validate_data"]
      lambda_name  = "validate_data"
    }
  ]
}

module "s3_uploads" {
  source               = "../../modules/s3_bucket"
  bucket_name          = "north-dev-uploads"
  cors_allowed_origins = ["https://tusitio.com"]
}


