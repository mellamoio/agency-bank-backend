provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "aws_agencias-bucket" {
  bucket = "aws-agencias-scotia-bucket-s3-v1"
  tags = {
    Environment = "dev"
    Project     = "Terraform-S3"
  }
}
