# DynamoDB Module: Defines the lock table for state locking

resource "aws_dynamodb_table" "terraform_locks" {
  name             = var.table_name
  billing_mode     = "PAY_PER_REQUEST" # Cost-effective option
  hash_key         = "LockID"

  attribute {
    name = "LockID"
    type = "S" # S for String. Must be named LockID
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Production"
  }
}

# --- Module Variables ---
variable "table_name" {
  description = "The name for the DynamoDB lock table."
  type        = string
}

# --- Module Outputs ---
output "table_name" {
  description = "The DynamoDB table name."
  value       = aws_dynamodb_table.terraform_locks.name
}

