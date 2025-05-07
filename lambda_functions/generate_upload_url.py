import os
import boto3
import urllib.parse
import json  # <-- Asegúrate de importar esto

s3 = boto3.client('s3')

def handler(event, context):
    bucket = os.environ['BUCKET_NAME']
    key = urllib.parse.unquote_plus(event['queryStringParameters']['filename'])

    url = s3.generate_presigned_url(
        'put_object',
        Params={'Bucket': bucket, 'Key': f"uploads/{key}"},
        ExpiresIn=600,
        HttpMethod='PUT'
    )

    return {
        "statusCode": 200,
        "headers": { "Content-Type": "application/json" },
        "body": json.dumps({ "url": url })  # <-- Esto es lo correcto
    }
