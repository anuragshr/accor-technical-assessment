terraform {
  required_version = ">= 1.5.7"


  # backend "s3" {
  #   bucket = "mybucket"           #placeholder for actual bucket name
  #   key    = "terraform.tfstate"  #path to the state file in the S3 bucket
  #   region = "us-east-1"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}




