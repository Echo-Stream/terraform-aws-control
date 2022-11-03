terraform {
  required_providers {
    aws = {
      configuration_aliases = [ aws.route-53 ]
      source  = "hashicorp/aws"
      version = ">=4.0.0"
    }
  }
  required_version = ">= 1.0"
}