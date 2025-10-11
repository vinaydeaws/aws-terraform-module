terraform {
  backend "s3" {
    bucket         = "production-terraform-state-bucket-unique-name-123"
    key            = "ec2/terraform.tfstate" # <-- Unique key for the EC2 state
    region         = "eu-north-1"
    dynamodb_table = "TerraformStateLock"
    encrypt        = true
  }
}
