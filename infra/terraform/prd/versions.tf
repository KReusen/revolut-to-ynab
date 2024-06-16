terraform {
  required_version = ">= 1.8, < 2.0"

  backend "s3" {
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.54"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}