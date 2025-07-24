from datetime import datetime

table = dynamodb.Table('baggage_tracking')

event = {
    "baggage_id": "BG123456",
    "event_timestamp": datetime.utcnow().isoformat(),
    "location": "YYZ_Gate_B",
    "status": "Loaded on aircraft"
}

table.put_item(Item=event)
