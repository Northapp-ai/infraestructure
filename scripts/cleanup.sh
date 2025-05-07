#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
    
    # Verificar jq
    if ! command_exists jq; then
        echo -e "${RED}Error: jq no está instalado${NC}"
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

# Función para inicializar Terraform
initialize_terraform() {
    echo -e "${YELLOW}Inicializando Terraform...${NC}"
    
    # Verificar si estamos en un directorio de ambiente
    if [ ! -f "main.tf" ] && [ ! -f "variables.tf" ]; then
        echo -e "${YELLOW}No se encontró configuración de Terraform en el directorio actual${NC}"
        echo -e "${YELLOW}Buscando directorios de ambiente...${NC}"
        
        # Buscar directorios de ambiente
        ENV_DIRS=($(find . -maxdepth 1 -type d -name "dev" -o -name "qa" -o -name "prod"))
        
        if [ ${#ENV_DIRS[@]} -eq 0 ]; then
            echo -e "${RED}No se encontraron directorios de ambiente${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}Directorios de ambiente encontrados:${NC}"
        for i in "${!ENV_DIRS[@]}"; do
            echo "$((i+1)). ${ENV_DIRS[$i]}"
        done
        
        read -p "Selecciona el número del ambiente (1-${#ENV_DIRS[@]}): " choice
        if [[ ! "$choice" =~ ^[1-9][0-9]*$ ]] || [ "$choice" -gt ${#ENV_DIRS[@]} ]; then
            echo -e "${RED}Selección inválida${NC}"
            exit 1
        fi
        
        cd "${ENV_DIRS[$((choice-1))]}"
    fi
    
    # Inicializar Terraform
    if ! terraform init -reconfigure; then
        echo -e "${RED}Error al inicializar Terraform${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Terraform inicializado${NC}"
}

# Función para limpiar un bucket S3
cleanup_bucket() {
    local bucket_name=$1
    echo -e "${YELLOW}Limpiando bucket S3: $bucket_name${NC}"
    
    # Verificar si el bucket existe
    if ! aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
        echo -e "${YELLOW}Bucket $bucket_name no existe o no tienes acceso${NC}"
        return 0
    fi
    
    # Eliminar versiones de objetos
    echo -e "${YELLOW}Eliminando versiones de objetos...${NC}"
    aws s3api delete-objects \
        --bucket "$bucket_name" \
        --delete "$(aws s3api list-object-versions \
            --bucket "$bucket_name" \
            --output json \
            --query '{Objects: [].{Key:Key,VersionId:VersionId}}')" 2>/dev/null
    
    # Eliminar marcadores de eliminación
    echo -e "${YELLOW}Eliminando marcadores de eliminación...${NC}"
    aws s3api delete-objects \
        --bucket "$bucket_name" \
        --delete "$(aws s3api list-object-versions \
            --bucket "$bucket_name" \
            --output json \
            --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')" 2>/dev/null
    
    # Eliminar todos los objetos
    echo -e "${YELLOW}Eliminando objetos...${NC}"
    aws s3 rm "s3://$bucket_name" --recursive
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Bucket S3 $bucket_name limpiado exitosamente${NC}"
        return 0
    else
        echo -e "${RED}✗ Error al limpiar bucket S3 $bucket_name${NC}"
        return 1
    fi
}

# Función principal
main() {
    echo -e "${YELLOW}Iniciando limpieza de recursos...${NC}"
    
    # Verificar requisitos previos
    check_prerequisites
    
    # Inicializar Terraform
    initialize_terraform
    
    # Obtener todos los buckets S3 del proyecto
    BUCKETS=($(terraform state list | grep "aws_s3_bucket" | sed 's/.*"\(.*\)".*/\1/'))
    
    if [ ${#BUCKETS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Encontrados ${#BUCKETS[@]} buckets S3 para limpiar${NC}"
        
        for BUCKET in "${BUCKETS[@]}"; do
            cleanup_bucket "$BUCKET"
        done
    else
        # Intentar obtener el bucket desde el output
        BUCKET_NAME=$(terraform output -raw main_s3_bucket_name 2>/dev/null)
        if [ ! -z "$BUCKET_NAME" ]; then
            cleanup_bucket "$BUCKET_NAME"
        fi
    fi
    
    # Obtener los grupos de logs desde el estado de Terraform
    LOG_GROUPS=$(terraform output -json lambda_function_arns 2>/dev/null | jq -r 'keys[]')
    
    if [ ! -z "$LOG_GROUPS" ]; then
        echo -e "${YELLOW}Limpiando grupos de logs...${NC}"
        
        for LOG_GROUP in $LOG_GROUPS; do
            echo -e "${YELLOW}Eliminando grupo de logs: $LOG_GROUP${NC}"
            aws logs delete-log-group --log-group-name "$LOG_GROUP"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Grupo de logs $LOG_GROUP eliminado${NC}"
            else
                echo -e "${RED}✗ Error al eliminar grupo de logs $LOG_GROUP${NC}"
            fi
        done
    fi
    
    # Verificar si hay recursos restantes
    REMAINING_RESOURCES=$(terraform state list 2>/dev/null)
    if [ ! -z "$REMAINING_RESOURCES" ]; then
        echo -e "${YELLOW}Recursos restantes en el estado:${NC}"
        echo "$REMAINING_RESOURCES"
    fi
    
    echo -e "${GREEN}Limpieza completada${NC}"
    echo -e "${YELLOW}Ahora puedes ejecutar 'terraform destroy'${NC}"
}

# Ejecutar función principal
main 