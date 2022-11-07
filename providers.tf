#This should be it until Terraform supports Dynamic provider configuration ##

########################## Africa ######################################
# af-south-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "af-south-1"
  alias               = "cape-town"
}

########################## Asia Pacific #################################
# ap-east-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "ap-east-1"
  alias               = "hongkong"
}

# ap-northeast-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "ap-northeast-1"
  alias               = "tokyo"
}

# ap-northeast-2 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "ap-northeast-2"
  alias               = "osaka"
}

# ap-south-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "ap-south-1"
  alias               = "mumbai"
}

# ap-southeast-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "ap-southeast-1"
  alias               = "singapore"
}

# ap-southeast-2 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "ap-southeast-2"
  alias               = "sydney"
}

######################### Canada ###################################
# ca-central-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "ca-central-1"
  alias               = "central"
}

######################### Europe ##################################
# eu-central-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "eu-central-1"
  alias               = "frankfurt"
}

# eu-north-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "eu-north-1"
  alias               = "stockholm"
}

# eu-south-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "eu-south-1"
  alias               = "milan"
}

# eu-west-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "eu-west-1"
  alias               = "ireland"
}

# eu-west-2 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "eu-west-2"
  alias               = "london"
}

# eu-west-3 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "eu-west-3"
  alias               = "paris"
}

#########################Middle East ##################################
# me-central-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "me-central-1"
  alias               = "uae"
}

# me-south-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "me-south-1"
  alias               = "bahrain"
}

#########################South America #################################
# sa-east-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "sa-east-1"
  alias               = "sao-paulo"
}

############################ United States ######################################
# us-east-1 (Aliased) aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "us-east-1"
  alias               = "north-virginia"
}

# us-east-2 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "us-east-2"
  alias               = "ohio"
}

# us-west-1 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "us-west-1"
  alias               = "north-california"
}

# us-west-2 aws provider
provider "aws" {
  allowed_account_ids = [data.aws_caller_identity.current.account_id]
  region              = "us-west-2"
  alias               = "oregon"
}
