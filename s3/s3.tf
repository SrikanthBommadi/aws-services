# Logging bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.logging_bucket_name
  force_destroy = true

  tags = {
    Purpose = "S3 Access Logs"
  }
}

# Logging bucket policy (allow log writes)
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowS3LoggingDelivery",
        Effect    = "Allow",
        Principal = {
          Service = "logging.s3.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.log_bucket.arn}/logs/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Main bucket
resource "aws_s3_bucket" "reddy_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = "Production"
    Owner       = "Reddy"
    Project     = "reddy.tf"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.reddy_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.reddy_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.reddy_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.reddy_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "logs/${var.bucket_name}/"
}

# Bucket policy to enforce SSE
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:PutObject"]

    resources = ["${aws_s3_bucket.reddy_bucket.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.reddy_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}
