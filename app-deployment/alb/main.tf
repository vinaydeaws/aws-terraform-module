# This configuration reads the network state and creates the ALB.

provider "aws" {
  region = var.aws_region
}

# Data source to read the outputs from the network's remote state file
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "production-terraform-state-bucket-unique-name-123"
    key    = "vpc/terraform.tfstate"
    region = var.aws_region
  }
}

module "alb" {
  # YOU MUST REPLACE THIS with your actual GitHub URL
  source = "git::https://github.com/vinaydeaws/aws-terraform-module.git//modules/alb_module?ref=main"

  project_name = var.project_name
  # Use the outputs from the network's state file
  vpc_id       = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_sg_id     = data.terraform_remote_state.vpc.outputs.private_sg_id
}

