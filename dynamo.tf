module "graph_table" {
  attribute = [
    {
      name = "pk"
      type = "S"
    },
    {
      name = "sk"
      type = "S"
    },
    {
      name = "lsi0_sk"
      type = "S"
    },
    {
      name = "gsi0_pk"
      type = "S"
    },
  ]

  billing_mode = "PAY_PER_REQUEST"

  global_secondary_index = [
    {
      hash_key        = "gsi0_pk"
      name            = "gsi0"
      projection_type = "ALL",
    }
  ]

  local_secondary_index = [
    {
      range_key       = "lsi0_sk"
      name            = "lsi0"
      projection_type = "ALL"
    }
  ]

  hash_key               = "pk"
  range_key              = "sk"
  name                   = "${var.environment_prefix}-graph"
  point_in_time_recovery = true
  stream_view_type       = "NEW_AND_OLD_IMAGES"

  source  = "QuiNovas/dynamodb-table/aws"
  version = "3.0.7"
}
