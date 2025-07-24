provider "aws" {
  region = "us-east-1"
}

module "booking_table" {
  source = "./modules/dynamodb"
  table_name = "booking_sessions"
}

module "booking_lambda" {
  source      = "./modules/lambda"
  function_name = "write_booking_session"
  table_name    = module.booking_table.table_name
}
##Dynamodb create
resource "aws_dynamodb_table" "booking_sessions" {
  name           = var.table_name
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

## variables
variable "table_name" {
  type = string
}

## lamda functions
resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}_exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "${var.function_name}_attach"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }
}

## lamda functions variables
variable "function_name" {
  type = string
}

variable "table_name" {
  type = string
}

##CLOUD WATCH

# resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
#   alarm_name          = "LambdaBookingErrors"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "Errors"
#   namespace           = "AWS/Lambda"
#   period              = "60"
#   statistic           = "Sum"
#   threshold           = 1

#   dimensions = {
#     FunctionName = module.booking_lambda.function_name
#   }

#   alarm_description = "Triggers when booking session lambda throws errors"
# }

# Frontend/Web App
#      |
#      ↓
# API Gateway (REST POST /session)
#      |
#      ↓
# Lambda (write_booking_session)
#      |
#      ↓
# DynamoDB (booking_sessions)
#      |
#      ↓
# TTL automatically expires stale sessions
