resource "aws_glue_catalog_database" "billing" {
  description = "Primary database for echostream billing; Cost/Usage, ManagedInstances"
  name        = "${var.resource_prefix}-billing"
}

###################################################
################### ALARMS ########################
###################################################

resource "aws_glue_catalog_table" "alarms" {
  name          = "alarms"
  database_name = aws_glue_catalog_database.billing.name
  description   = "Alarms"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification"      = "parquet"
    "parquet.compression" = "SNAPPY"
    EXTERNAL              = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.cost_and_usage.id}/alarms/"
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
      name    = "count"
      type    = "bigint"
      comment = "The alarm count"
    }

    columns {
      name    = "end"
      type    = "timestamp"
      comment = "The timestamp when alarm count ends, exclusive"
    }

    columns {
      name    = "identity"
      type    = "string"
      comment = "Tenant identity"
    }

    columns {
      name    = "start"
      type    = "timestamp"
      comment = "The timestamp when alarm count starts, inclusive"
    }
  }
}

###################################################
############## MANAGED INSTANCES ##################
###################################################

resource "aws_glue_catalog_table" "managed_instances" {
  name          = "managedinstances"
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
      name    = "id"
      type    = "string"
      comment = "Managed Instance ID"
    }

    columns {
      name    = "identity"
      type    = "string"
      comment = "Tenant identity"
    }

    columns {
      name    = "tenant"
      type    = "string"
      comment = "The name of the Tenant"
    }

    columns {
      name    = "registration"
      type    = "timestamp"
      comment = "The timestamp when the registration occurred"
    }
  }
}

###################################################
#################### TENANTS ######################
###################################################

resource "aws_glue_catalog_table" "tenants" {
  name          = "tenants"
  database_name = aws_glue_catalog_database.billing.name
  description   = "Tenants"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification"      = "parquet"
    "parquet.compression" = "SNAPPY"
    EXTERNAL              = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.cost_and_usage.id}/tenants/"
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
      name    = "created"
      type    = "timestamp"
      comment = "The timestamp when the tenant was created"
    }

    columns {
      name    = "identity"
      type    = "string"
      comment = "Tenant identity"
    }

    columns {
      name    = "name"
      type    = "string"
      comment = "The name of the Tenant"
    }

    columns {
      name    = "subscriptionid"
      type    = "string"
      comment = "The subscription ID for the Tenant"
    }
  }
}

###################################################
################ COST AND USAGE ###################
###################################################
resource "aws_glue_crawler" "cost_and_usage" {
  database_name = aws_glue_catalog_database.billing.name
  description   = "Keeps costandusage reports table up to date in Athena"
  name          = "${var.resource_prefix}-cost-and-usage"
  role          = aws_iam_role.cost_and_usage_crawler.arn
  schedule      = "cron(0 3 * * ? *)"
  tags          = local.tags

  s3_target {
    path = "s3://${aws_s3_bucket.cost_and_usage.id}/exports/${local.cost_and_usage_export_name}/data/"
  }

  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  table_prefix = "costandusage"
}

resource "aws_iam_role" "cost_and_usage_crawler" {
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
  name               = "${var.resource_prefix}-cost-and-usage-crawler"
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "cost_and_usage_crawler" {
  role       = aws_iam_role.cost_and_usage_crawler.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy_document" "cost_and_usage_crawler" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.cost_and_usage.arn}/exports/${local.cost_and_usage_export_name}/*",
    ]

    sid = "MinimumPermissionsToCrawl"
  }
}

resource "aws_iam_role_policy" "cost_and_usage_crawler" {
  name   = "${var.resource_prefix}-cost-and-usage-crawler"
  policy = data.aws_iam_policy_document.cost_and_usage_crawler.json
  role   = aws_iam_role.cost_and_usage_crawler.id
}
