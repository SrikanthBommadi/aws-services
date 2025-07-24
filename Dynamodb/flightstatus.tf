resource "aws_dynamodb_table" "flight_status" {
  name         = "flight_status"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "flight_id"

  attribute {
    name = "flight_id"
    type = "S"
  }

  tags = {
    Team = "ops"
  }
}
