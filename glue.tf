resource "aws_glue_catalog_database" "billing" {
  description = "Primary database for echostream billing. Cost/Usage, ManagedInstances tables"
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