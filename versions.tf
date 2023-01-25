terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">=2.2.0"
    }
    aws = {
      configuration_aliases = [aws.route-53]
      source                = "hashicorp/aws"
      version               = ">=4.0.0"
    }
    stripe = {
      source  = "lukasaron/stripe"
      version = ">=1.6.0"
    }
  }
  required_version = ">= 1.3"
}