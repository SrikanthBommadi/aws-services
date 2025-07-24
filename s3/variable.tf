variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     =  "chatbot-itgen"  ##reddy.tf"
}

variable "logging_bucket_name" {
  description = "Bucket name where logs will be stored"
  type        = string
  default     = "reddy-log-bucket"
}
