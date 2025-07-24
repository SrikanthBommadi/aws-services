import boto3
import os
import time
import json

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['TABLE_NAME']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    body = json.loads(event['body'])

    session_id = body['session_id']
    user_id = body['user_id']
    expires_in = body.get('ttl_seconds', 1800)

    item = {
        "session_id": session_id,
        "user_id": user_id,
        "flight_options": body.get('flight_options', {}),
        "seat_selection": body.get('seat_selection', {}),
        "expires_at": int(time.time()) + expires_in
    }

    table.put_item(Item=item)

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Session stored", "session_id": session_id})
    }
