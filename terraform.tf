terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8.0"
    }
      docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }


    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87"
    }    
  }
  required_version = "~> 1.7"

  backend "s3" {
    bucket         = "mg-tf-state-backend"
    key            = "state/terraform.bedrock-tf-agent"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "my-terraform-lockdb"
  }
}
