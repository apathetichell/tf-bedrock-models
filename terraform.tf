terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87"
    }    
  }
  required_version = "~> 1.7"

  backend "s3" {
    bucket         = "mg-tf-state-backend"
    key            = "state/terraform.sf-tf-s3-sample-state"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "my-terraform-lockdb"
  }
}
