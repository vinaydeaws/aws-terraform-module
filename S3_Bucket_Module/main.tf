# S3 Module: Defines the S3 bucket for Terraform state storage

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "Terraform State Backend"
    Environment = "Production"
  }
}

# Enforce server-side encryption (SSE-S3 is a good default for state files)
resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_sse" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable Versioning (CRITICAL: allows recovering from accidental state deletion)
resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access (CRITICAL for security)
resource "aws_s3_bucket_public_access_block" "state_bucket_block_public" {
  bucket                  = aws_s3_bucket.terraform_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Module Variables ---
variable "bucket_name" {
  description = "The unique name for the S3 bucket."
  type        = string
}

variable "region" {
  description = "The AWS region for the bucket."
  type        = string
}

# --- Module Outputs ---
output "bucket_id" {
  description = "The S3 bucket ID/name."
  value       = aws_s3_bucket.terraform_state_bucket.id
}

