import boto3
from datetime import datetime
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('PromoCodes')

def lambda_handler(event, context):
    code = event.get('queryStringParameters', {}).get('code')
    if not code:
        return {'statusCode': 400, 'body': 'Promo code required'}

    response = table.get_item(Key={'code': code})
    item = response.get('Item')

    if not item:
        return {'statusCode': 404, 'body': 'Invalid promo code'}

    # Check expiry
    if datetime.utcnow().strftime('%Y-%m-%d') > item['expiry']:
        return {'statusCode': 410, 'body': 'Promo code expired'}

    # Check usage
    if item['usedCount'] >= item['usageLimit']:
        return {'statusCode': 429, 'body': 'Promo code limit reached'}

    # Update usage count (OPTIONAL: Add conditional expression for concurrency)
    table.update_item(
        Key={'code': code},
        UpdateExpression="SET usedCount = usedCount + :inc",
        ExpressionAttributeValues={':inc': 1}
    )

    return {
        'statusCode': 200,
        'body': f"Promo valid. Discount: {item['discount']} ({item['type']})"
    }
