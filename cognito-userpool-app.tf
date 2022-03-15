module "lambda_underpin_us_east_2" {
  name = var.resource_prefix
  tags = local.tags

  source = "./_modules/lambda-underpin"

  providers = {
    aws = aws.ohio
  }
}

# ###############################
# # App Cognito Pool us-east-2 ##
# ###############################
# module "app_cognito_pool_us_east_2" {
#   count = contains(local.regions, "us-east-2") == true ? 1 : 0


#   artifacts_bucket = local.artifacts_bucket
#   control_region   = local.current_region
#   environment      = var.resource_prefix
#   graph_table_name = module.graph_table.name
#   name             = "${local.resource_prefix}-us-east-2"
#   tags             = local.tags
#   tenant_regions   = jsonencode(local.tenant_regions)
#   providers = {
#     aws = aws.us-east-2
#   }
# }