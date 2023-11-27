# Librerías necesarias
import json
import boto3
import urllib.parse

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('DBjuan-EjFinal-terraform')
bucket_name = 's3terraformejfinal'

def lambda_handler(event, _):
    # Comprueba si el evento proviene de S3
    if 'Records' in event and 's3' in event['Records'][0]:
        # El evento es un archivo nuevo en S3
        file_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        content = response['Body'].read().decode('utf-8')
        data = json.loads(content)

        # Inserta los datos en la tabla DynamoDB
        response = table.put_item(Item=data)

        return {
            'statusCode': 200,
            'body': json.dumps('Datos insertados en DynamoDB')
        }
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Evento no válido')
        }