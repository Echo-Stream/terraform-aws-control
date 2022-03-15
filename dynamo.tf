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
      name = "gsi0_pk"
      type = "S"
    },
    {
      name = "gsi1_pk"
      type = "S"
    },
    {
      name = "gsi2_pk"
      type = "S"
    },
    {
      name = "gsi3_pk"
      type = "S"
    },
    {
      name = "lsi0_sk"
      type = "S"
    },
    {
      name = "lsi1_sk"
      type = "S"
    },
    {
      name = "lsi2_sk"
      type = "S"
    },
    {
      name = "lsi3_sk"
      type = "S"
    },
    {
      name = "lsi4_sk"
      type = "S"
    },
    {
      name = "gsi3_sk"
      type = "S"
    },
  ]

  billing_mode = "PAY_PER_REQUEST"

  global_secondary_index = [
    {
      hash_key        = "gsi0_pk"
      name            = "gsi0"
      projection_type = "ALL",
    },
    {
      hash_key        = "gsi1_pk"
      name            = "gsi1"
      projection_type = "ALL",
    },
    {
      hash_key        = "gsi2_pk"
      name            = "gsi2"
      projection_type = "ALL",
    },
    {
      hash_key        = "gsi3_pk"
      range_key       = "gsi3_sk"
      name            = "gsi3"
      projection_type = "ALL",
    },
  ]

  local_secondary_index = [
    {
      range_key       = "lsi0_sk"
      name            = "lsi0"
      projection_type = "ALL"
    },
    {
      range_key       = "lsi1_sk"
      name            = "lsi1"
      projection_type = "ALL"
    },
    {
      range_key       = "lsi2_sk"
      name            = "lsi2"
      projection_type = "ALL"
    },
    {
      range_key       = "lsi3_sk"
      name            = "lsi3"
      projection_type = "ALL"
    },
    {
      range_key       = "lsi4_sk"
      name            = "lsi4"
      projection_type = "ALL"
    },
  ]

  hash_key               = "pk"
  range_key              = "sk"
  name                   = "${var.resource_prefix}-graph"
  point_in_time_recovery = true
  ttl_attribute_name     = "ttl"
  stream_view_type       = "NEW_AND_OLD_IMAGES"

  replica = [
    for region in setsubtract(local.tenant_regions, [local.current_region]) :
    {
      region_name = region
    }
  ]


  source  = "QuiNovas/dynamodb-table/aws"
  version = "3.0.8"
}