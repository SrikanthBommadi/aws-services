terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.3.0"
    }
  }
  # backend "s3" {
  #   bucket = "reddy.tf"
  #   key    = "statesave"
  #   region = "us-east-1"
  # }
}
provider "aws" {
  # Configuration options
}