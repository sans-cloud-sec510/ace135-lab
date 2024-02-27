terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {
}
