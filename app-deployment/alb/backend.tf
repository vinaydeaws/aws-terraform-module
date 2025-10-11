terraform {
  backend "s3" {
    bucket         = "production-terraform-state-bucket-unique-name-123"
    key            = "ALB/terraform.tfstate" # <-- Unique key for the ALB state
    region         = "eu-north-1"
    dynamodb_table = "TerraformStateLock"
    encrypt        = true
  }
}
