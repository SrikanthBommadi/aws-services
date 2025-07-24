import boto3
import time
from datetime import datetime, timedelta

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('booking_sessions')

session_item = {
    "session_id": "sess_1001",
    "user_id": "user_123",
    "flight_options": {"origin": "YYZ", "destination": "LAX"},
    "seat_selection": {"seat": "12A"},
    "expires_at": int(time.time()) + 1800  # 30 min from now
}

table.put_item(Item=session_item)
