import json
import boto3
import os

def lambda_handler(event, context):
    print("Evento recibido:", json.dumps(event))
    
    trigger_source = event.get('triggerSource')
    print("Trigger source:", trigger_source)
    
    # Ejemplo: guardar usuario solo en registro (PreSignUp o PostConfirmation)
    if trigger_source in ['PreSignUp_SignUp', 'PostConfirmation_ConfirmSignUp']:
        user_attributes = event['request']['userAttributes']
        print("Atributos del usuario:", user_attributes)
        
        # Guardar usuario en DynamoDB (si aplica)
        dynamodb = boto3.resource('dynamodb')
        table_name = os.environ.get('USERS_TABLE')
        table = dynamodb.Table(table_name)
        
        # Ejemplo de guardado (ajusta los campos según tu modelo)
        table.put_item(Item={
            'username': event['userName'],
            'email': user_attributes.get('email', ''),
            'sub': user_attributes.get('sub', ''),
            # ...otros atributos que quieras guardar...
        })
        print("Usuario guardado en DynamoDB")
    
    # Puedes agregar lógica para otros triggers aquí
    # if trigger_source == 'CustomMessage_SignUp':
    #     # Personalizar mensaje, etc.
    
    return event
