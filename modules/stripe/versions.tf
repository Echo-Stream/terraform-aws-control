terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0.0"
    }
    stripe = {
      source      = "lukasaron/stripe"
      versversion = ">=1.6.0"
    }
  }
  required_version = ">= 1.0"
}
