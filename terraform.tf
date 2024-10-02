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
  }
  required_version = "~> 1.7"
  }
