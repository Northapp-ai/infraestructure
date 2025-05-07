#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables
BUCKET_NAME="north-terraform-state-bucket"
DYNAMODB_TABLE="north-terraform-state-lock"
REGION="us-east-1"

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar requisitos previos
check_prerequisites() {
    echo -e "${YELLOW}Verificando requisitos previos...${NC}"
    
    # Verificar AWS CLI
    if ! command_exists aws; then
        echo -e "${RED}Error: AWS CLI no está instalado${NC}"
        exit 1
    fi
    
    # Verificar Terraform
    if ! command_exists terraform; then
        echo -e "${RED}Error: Terraform no está instalado${NC}"
        exit 1
    fi
    
    # Verificar credenciales AWS
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo -e "${RED}Error: No hay credenciales AWS configuradas${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Requisitos previos verificados${NC}"
}

# Función para crear recursos AWS
create_aws_resources() {
    echo -e "${YELLOW}Inicializando recursos AWS...${NC}"
    
    # Verificar si el bucket existe
    if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo -e "${YELLOW}Creando bucket S3 para el estado de Terraform...${NC}"
        
        # Crear el bucket (manejo especial para us-east-1)
        if [ "$REGION" = "us-east-1" ]; then
            if aws s3api create-bucket \
                --bucket "$BUCKET_NAME" \
                --region "$REGION"; then
                echo -e "${GREEN}✓ Bucket S3 creado exitosamente${NC}"
            else
                echo -e "${RED}✗ Error al crear el bucket S3${NC}"
                exit 1
            fi
        else
            if aws s3api create-bucket \
                --bucket "$BUCKET_NAME" \
                --region "$REGION" \
                --create-bucket-configuration LocationConstraint="$REGION"; then
                echo -e "${GREEN}✓ Bucket S3 creado exitosamente${NC}"
            else
                echo -e "${RED}✗ Error al crear el bucket S3${NC}"
                exit 1
            fi
        fi
        
        # Habilitar versionamiento
        echo -e "${YELLOW}Habilitando versionamiento...${NC}"
        aws s3api put-bucket-versioning \
            --bucket "$BUCKET_NAME" \
            --versioning-configuration Status=Enabled
            
        # Habilitar encriptación
        echo -e "${YELLOW}Habilitando encriptación...${NC}"
        aws s3api put-bucket-encryption \
            --bucket "$BUCKET_NAME" \
            --server-side-encryption-configuration '{
                "Rules": [
                    {
                        "ApplyServerSideEncryptionByDefault": {
                            "SSEAlgorithm": "AES256"
                        }
                    }
                ]
            }'
            
        # Bloquear acceso público
        echo -e "${YELLOW}Bloqueando acceso público...${NC}"
        aws s3api put-public-access-block \
            --bucket "$BUCKET_NAME" \
            --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    else
        echo -e "${GREEN}✓ Bucket S3 ya existe${NC}"
    fi
    
    # Verificar si la tabla DynamoDB existe
    if ! aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" 2>/dev/null; then
        echo -e "${YELLOW}Creando tabla DynamoDB para bloqueo de estado...${NC}"
        
        # Crear la tabla
        if aws dynamodb create-table \
            --table-name "$DYNAMODB_TABLE" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5; then
            
            echo -e "${GREEN}✓ Tabla DynamoDB creada exitosamente${NC}"
        else
            echo -e "${RED}✗ Error al crear la tabla DynamoDB${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Tabla DynamoDB ya existe${NC}"
    fi
    
    # Verificar si la KMS key existe
    if ! aws kms describe-key --key-id "alias/north-terraform-state-key" 2>/dev/null; then
        echo -e "${YELLOW}Creando KMS key para encriptación...${NC}"
        
        # Crear la KMS key
        if aws kms create-alias \
            --alias-name "alias/north-terraform-state-key" \
            --target-key-id "$(aws kms create-key --description "Terraform state encryption key" --query 'KeyMetadata.KeyId' --output text)"; then
            
            echo -e "${GREEN}✓ KMS key creada exitosamente${NC}"
        else
            echo -e "${RED}✗ Error al crear la KMS key${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ KMS key ya existe${NC}"
    fi
}

# Función para inicializar Terraform
initialize_terraform() {
    echo -e "${YELLOW}Inicializando Terraform...${NC}"
    
    # Verificar si hay un estado local
    if [ -f ".terraform/terraform.tfstate" ]; then
        echo -e "${YELLOW}Se encontró un estado local. Intentando migrar...${NC}"
        if ! terraform init -migrate-state; then
            echo -e "${YELLOW}La migración falló. Intentando reconfigurar...${NC}"
            if ! terraform init -reconfigure; then
                echo -e "${RED}Error al inicializar Terraform${NC}"
                exit 1
            fi
        fi
    else
        # Inicialización normal
        if ! terraform init; then
            echo -e "${RED}Error al inicializar Terraform${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✓ Terraform inicializado exitosamente${NC}"
}

# Función principal
main() {
    # Verificar requisitos previos
    check_prerequisites
    
    # Crear recursos AWS
    create_aws_resources
    
    # Inicializar Terraform
    initialize_terraform
    
    echo -e "${GREEN}✓ Backend inicializado exitosamente${NC}"
    echo -e "${YELLOW}Ahora puedes ejecutar 'terraform plan'${NC}"
}

# Ejecutar función principal
main 