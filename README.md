# Infraestructura AWS con Terraform

Este proyecto contiene la infraestructura como código (IaC) para desplegar recursos en AWS utilizando Terraform.

## Estructura del Proyecto

```
.
├── environments/          # Configuraciones específicas por ambiente
│   ├── dev/              # Ambiente de desarrollo
│   ├── qa/               # Ambiente de pruebas
│   └── prod/             # Ambiente de producción
├── modules/              # Módulos reutilizables de Terraform
│   ├── api_gateway/      # Configuración de API Gateway
│   ├── cognito/          # Configuración de Amazon Cognito
│   ├── dynamodb_tables/  # Tablas DynamoDB
│   ├── lambda_functions/ # Funciones Lambda
│   └── s3_bucket/        # Buckets S3
└── lambda_functions/     # Código fuente de las funciones Lambda
```

## Requisitos Previos

- Terraform >= 1.5.0
- AWS CLI configurado con credenciales válidas
- Acceso a una cuenta AWS con los permisos necesarios

## Configuración Inicial

1. Clonar el repositorio:
```bash
git clone <url-del-repositorio>
cd infraestructure
```

2. Inicializar Terraform en el ambiente deseado:
```bash
cd environments/dev  # o qa/prod según el ambiente
terraform init
terraform plan
terraform apply
```

## Despliegue

Para desplegar la infraestructura:

```bash
terraform plan    # Revisar los cambios
terraform apply   # Aplicar los cambios
```

Para destruir la infraestructura:

```bash
terraform destroy -auto-approve
```

## Gestión de Usuarios Cognito

### Crear un nuevo usuario

```bash
aws cognito-idp admin-create-user \
  --user-pool-id us-east-1_Iivs6XGJc \
  --username testuser \
  --user-attributes Name=email,Value=testuser@example.com Name=email_verified,Value=true \
  --message-action SUPPRESS
```

### Establecer contraseña permanente

```bash
aws cognito-idp admin-set-user-password \
  --user-pool-id us-east-1_Iivs6XGJc \
  --username juan \
  --password "TuContraseñaSegura123" \
  --permanent
```

## Módulos Principales

### API Gateway
Configuración de endpoints REST/HTTP para exponer servicios.

### Cognito
Gestión de autenticación y autorización de usuarios.

### DynamoDB
Tablas NoSQL para almacenamiento de datos.

### Lambda Functions
Funciones serverless para procesamiento de eventos.

### S3 Bucket
Almacenamiento de objetos y archivos.

## Ejemplos de Uso

### Invocar Lambda Function
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "1234567890"
}
```

## Contribución

1. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
2. Commit de tus cambios (`git commit -m 'Add some AmazingFeature'`)
3. Push a la rama (`git push origin feature/AmazingFeature`)
4. Abrir un Pull Request

## Soporte

Para reportar problemas o solicitar ayuda, por favor crear un issue en el repositorio.

## Licencia

Este proyecto está bajo la Licencia MIT con Cláusula de IA - ver el archivo [LICENSE](LICENSE) para más detalles.

La licencia permite:
- Uso, modificación y distribución del software
- Uso con sistemas de IA y machine learning
- Generación de trabajos derivados
- Procesamiento de datos con IA

Con las siguientes condiciones:
- Atribución requerida
- Documentación de modificaciones por IA
- Cumplimiento de leyes de privacidad y protección de datos
- Marcado de contenido generado por IA




aws cognito-idp admin-update-user-attributes \
  --user-pool-id us-east-1_Iivs6XGJc \
  --username juan \
  --user-attributes Name=email_verified,Value=true


aws cognito-idp admin-set-user-password \
  --user-pool-id us-east-1_Iivs6XGJc \
  --username juan \
  --password "TuContraseñaSegura123" \
  --permanent




aws cognito-idp admin-create-user \
  --user-pool-id us-east-1_Iivs6XGJc \
  --username testnuevo3 \
  --user-attributes Name=email,Value=testnuevo3@example.com Name=email_verified,Value=true \
  --message-action SUPPRESS


aws cognito-idp admin-set-user-password \
  --user-pool-id us-east-1_Iivs6XGJc  \
  --username testnuevo3 \
  --password "UnaPasswordSegura123" \
  --permanent 


aws cognito-idp admin-confirm-sign-up \
  --user-pool-id us-east-1_Iivs6XGJc \
  --username testnuevo3