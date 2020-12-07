module "billing" {
  environment_prefix = var.environment_prefix
  tags               = local.tags
  source             = "./_modules/billing"
}