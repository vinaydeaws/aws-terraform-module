# This configuration reads both network and ALB states to create EC2 instances.

provider "aws" {
  region = var.aws_region
}

# Read network state
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "production-terraform-state-bucket-unique-name-123"
    key    = "vpc/terraform.tfstate"
    region = var.aws_region
  }
}

# Read load balancer state
data "terraform_remote_state" "ALB" {
  backend = "s3"
  config = {
    bucket = "production-terraform-state-bucket-unique-name-123"
    key    = "ALB/terraform.tfstate"
    region = var.aws_region
  }
}

module "ec2" {
  # YOU MUST REPLACE THIS with your actual GitHub URL
  source = "git::https://github.com/vinaydeaws/aws-terraform-module.git//modules/ec2_module?ref=main"

  project_name       = var.project_name
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_sg_id       = data.terraform_remote_state.vpc.outputs.public_sg_id
  private_sg_id      = data.terraform_remote_state.vpc.outputs.private_sg_id
  target_group_arn   = data.terraform_remote_state.ALB.outputs.target_group_arn
}

