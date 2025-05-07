variable "deployment_environment" {
  description = "Environment name (development, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource identification"
  type        = string
  default     = "north"
}

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "resource_tags" {
  description = "Common tags to be applied to all AWS resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "north"
    ManagedBy   = "terraform"
    Owner       = "infrastructure-team"
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_resource_encryption" {
  description = "Enable encryption for sensitive resources"
  type        = bool
  default     = true
}

variable "log_retention_period" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
} 