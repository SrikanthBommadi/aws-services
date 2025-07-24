resource "aws_dynamodb_table" "baggage_tracking" {
  name         = "baggage_tracking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "baggage_id"
  range_key    = "event_timestamp"

  attribute {
    name = "baggage_id"
    type = "S"
  }

  attribute {
    name = "event_timestamp"
    type = "S"
  }
}
