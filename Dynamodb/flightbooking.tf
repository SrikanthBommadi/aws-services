resource "aws_dynamodb_table" "booking_sessions" {
  name           = "booking_sessions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "session_id"

  attribute {
    name = "session_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = {
    Environment = "prod"
    Team        = "devops"
  }
}
