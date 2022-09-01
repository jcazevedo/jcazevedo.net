terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "jcazevedo-terraform-state"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}
