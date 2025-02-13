import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb', region_name='us-east-2')  # Set correct region
table = dynamodb.Table('Resume')

def lambda_handler(event, context):
    try:
        response = table.get_item(Key={'Id': 1})  # Ensure correct case & type

        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'message': 'Resume not found'})
            }

        # Extract item while maintaining the order of fields
        item = response['Item']
        ordered_response = {
            #"Id": item.get("Id", ""),
            "awards": item.get("awards", []),
            "basics": item.get("basics", {}),
            "certificates": item.get("certificates", []),
            "education": item.get("education", []),
            "interests": item.get("interests", []),
            "languages": item.get("languages", []),
            "projects": item.get("projects", []),
            "publications": item.get("publications", []),
            "references": item.get("references", []),
            "skills": item.get("skills", []),
            "volunteer": item.get("volunteer", []),
            "work": item.get("work", [])
        }

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(ordered_response)
        }

    except ClientError as e:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': e.response['Error']['Message']})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Internal Server Error', 'error': str(e)})
        }
