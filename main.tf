terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  profile = "lucamandelli"
  region  = "us-east-2"
}
