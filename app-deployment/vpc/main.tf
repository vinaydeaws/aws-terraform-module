# This configuration only creates the VPC and related networking resources.

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  # YOU MUST REPLACE THIS with your actual GitHub URL
  source = "git::https://github.com/vinaydeaws/aws-terraform-module.git//modules/vpc_module?ref=main"

  project_name = var.project_name
  cidr_block   = "10.0.0.0/16"
}

