import json
import boto3
import os

def lambda_handler(event, context):
    try:
        # Obtener los datos del evento
        body = json.loads(event.get('body', '{}'))
        
        # Validar los datos requeridos
        required_fields = ['name', 'email', 'phone']
        missing_fields = [field for field in required_fields if field not in body]
        
        if missing_fields:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'Campos requeridos faltantes',
                    'missing_fields': missing_fields
                })
            }
        
        # Validar formato de email
        if '@' not in body['email']:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'Formato de email inválido'
                })
            }
        
        # Validar formato de teléfono (solo números)
        if not body['phone'].isdigit():
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'El teléfono debe contener solo números'
                })
            }
        
        # Si todo es válido, retornar éxito
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Datos validados correctamente',
                'data': body
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Error interno del servidor: {str(e)}'
            })
        } 