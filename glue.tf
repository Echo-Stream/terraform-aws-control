resource "aws_glue_catalog_database" "billing" {
  description = "Primary database for echostream billing; Cost/Usage, ManagedInstances"
  name        = "${var.resource_prefix}-billing"
}

resource "aws_glue_catalog_table" "managed_instances" {
  name          = "${var.resource_prefix}-managed-instances"
  database_name = aws_glue_catalog_database.billing.name
  description   = "Managed Instances"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification"      = "parquet"
    "parquet.compression" = "SNAPPY"
    EXTERNAL              = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.cost_and_usage.id}/managed-instances/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name    = "id"
      type    = "string"
      comment = "Managed Instance ID"
    }

    columns {
      name    = "app"
      type    = "string"
      comment = "The name of the Managed App"
    }

    columns {
      name    = "appid"
      type    = "string"
      comment = "Managed App ID"
    }

    columns {
      name    = "tenant"
      type    = "string"
      comment = "The name of the Tenant"
    }

    columns {
      name    = "timestamp"
      type    = "string"
      comment = "The timestamp when the record is written"
    }
  }
}

###################################################
################ COST AND USAGE ###################
###################################################
resource "aws_glue_crawler" "cost_and_usage_crawler" {
  database_name = aws_glue_catalog_database.billing.name
  description   = "Lambda invoked crawler that keeps cost and usage reports table up to date in Athena"
  name          = "${var.resource_prefix}-cost-and-usage-crawler"
  role          = aws_iam_role.cost_and_usage_crawler.arn
  tags          = local.tags

  s3_target {
    path       = "s3://${aws_s3_bucket.cost_and_usage.id}/reports/CostAndUsage/CostAndUsage"
    exclusions = ["**.json", "**.yml", "**.sql", "**.csv", "**.zip", "**.gz"]
  }

  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

resource "aws_iam_role" "cost_and_usage_crawler" {
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-cost-and-usage-crawler"
    policy = data.aws_iam_policy_document.cost_and_usage_crawler.json
  }
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"]
  name                = "${var.resource_prefix}-cost-and-usage-crawler"
  tags                = local.tags
}

data "aws_iam_policy_document" "cost_and_usage_crawler" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.cost_and_usage.arn}/reports/CostAndUsage/CostAndUsage/*",
    ]

    sid = "MinimumPermissionsToCrawl"
  }
}
