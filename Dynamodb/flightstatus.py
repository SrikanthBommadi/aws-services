flight_id = "AC845#2025-07-13"

table = dynamodb.Table('flight_status')

update = {
    "flight_id": flight_id,
    "departure_time": "09:45",
    "gate": "C12",
    "status": "Boarding",
    "last_updated": datetime.utcnow().isoformat()
}

table.put_item(Item=update)
