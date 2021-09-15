# AWS Provider for user-provided region
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = var.region
}

## This should be it until Terraform supports Dynamic provider configuration ##

############################# US Regions ######################################
# us-east-1 (Aliased) aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-east-1"
  alias               = "north-virginia"
}

# us-east-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-east-2"
  alias               = "us-east-2"
}

# us-west-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-west-1"
  alias               = "us-west-1"
}

# us-west-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-west-2"
  alias               = "us-west-2"
}

########################### Africa ######################################
# af-south-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "af-south-1"
  alias               = "af-south-1"
}

########################### Asia Pacific #################################
# ap-east-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "ap-east-1"
  alias               = "ap-east-1"
}

# ap-south-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "ap-south-1"
  alias               = "ap-south-1"
}

# ap-northeast-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "ap-northeast-2"
  alias               = "ap-northeast-2"
}

# ap-southeast-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "ap-southeast-1"
  alias               = "ap-southeast-1"
}

# ap-southeast-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "ap-southeast-2"
  alias               = "ap-southeast-2"
}

# ap-northeast-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "ap-northeast-1"
  alias               = "ap-northeast-1"
}

########################## Canada ###################################
# ca-central-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "ca-central-1"
  alias               = "ca-central-1"
}

########################## Europe ################################### 
# eu-central-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "eu-central-1"
  alias               = "eu-central-1"
}

# eu-west-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "eu-west-1"
  alias               = "eu-west-1"
}

# eu-west-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "eu-west-2"
  alias               = "eu-west-2"
}

# eu-south-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "eu-south-1"
  alias               = "eu-south-1"
}

# eu-west-3 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "eu-west-3"
  alias               = "eu-west-3"
}

# eu-north-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "eu-north-1"
  alias               = "eu-north-1"
}

########################## Middle East ################################### 
# me-south-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "me-south-1"
  alias               = "me-south-1"
}

########################## South America #################################
# sa-east-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "sa-east-1"
  alias               = "sa-east-1"
}