module "alarms" {
   lambdas = {
       appsync_kms_key_datasource = module.appsync_kms_key_datasource.name
   }
       source = "./_modules/lambda-alarms"
   }