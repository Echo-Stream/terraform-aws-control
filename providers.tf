# AWS Provider for user-provided region
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = var.region
}

# Provider for Managing DNS
provider "aws" {
  alias               = "route-53"
  allowed_account_ids = [var.route53_account_id] # Usually corporate account id

  assume_role {
    role_arn = "arn:aws:iam::${var.route53_account_id}:role/${var.route53_manager_role_name}"
  }

  region = "us-east-1"
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
  alias               = "ohio"
}

# us-west-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-west-1"
  alias               = "north-california"
}

# us-west-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-west-2"
  alias               = "oregon"
}

# ########################### Africa ######################################
# # af-south-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "af-south-1"
#   alias               = "cape-town"
# }

# ########################### Asia Pacific #################################
# # ap-east-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "ap-east-1"
#   alias               = "hongkong"
# }

# # ap-south-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "ap-south-1"
#   alias               = "mumbai"
# }

# # ap-northeast-2 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "ap-northeast-2"
#   alias               = "osaka"
# }

# # ap-southeast-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "ap-southeast-1"
#   alias               = "singapore"
# }

# # ap-southeast-2 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "ap-southeast-2"
#   alias               = "sydney"
# }

# # ap-northeast-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "ap-northeast-1"
#   alias               = "tokyo"
# }

# ########################## Canada ###################################
# # ca-central-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "ca-central-1"
#   alias               = "central"
# }

# ########################## Europe ################################### 
# # eu-central-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "eu-central-1"
#   alias               = "frankfurt"
# }

#eu-west-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "eu-west-1"
  alias               = "ireland"
}

# # eu-west-2 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "eu-west-2"
#   alias               = "london"
# }

# # eu-south-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "eu-south-1"
#   alias               = "milan"
# }

# # eu-west-3 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "eu-west-3"
#   alias               = "paris"
# }

# # eu-north-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "eu-north-1"
#   alias               = "stockholm"
# }

# ########################## Middle East ################################### 
# # me-south-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "me-south-1"
#   alias               = "bahrain"
# }

# ########################## South America #################################
# # sa-east-1 aws provider
# provider "aws" {
#   allowed_account_ids = [var.allowed_account_id]
#   region              = "sa-east-1"
#   alias               = "sao-paulo"
# }