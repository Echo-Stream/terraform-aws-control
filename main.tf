###############################
## General Account Resources ##
###############################
module "log_bucket" {
  name_prefix = var.resource_prefix
  tags        = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"
}

resource "aws_iam_service_linked_role" "dynamo_db_replication" {
  count            = var.create_dynamo_db_replication_service_role ? 1 : 0
  aws_service_name = "replication.dynamodb.amazonaws.com"
}
