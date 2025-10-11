terraform {
  backend "s3" {
    # This should match the bucket you already created
    bucket         = "production-terraform-state-bucket-unique-name-123"
    key            = "vpc/terraform.tfstate" # <-- Unique key for the network state
    region         = "eu-north-1"
    dynamodb_table = "TerraformStateLock"
    encrypt        = true
  }
}
