####################################################
### Audit Records Glue Catalog DB/Tables/Crawler ###
####################################################
resource "aws_glue_catalog_database" "audit_records" {
  description = "Audit Records"
  name        = "${replace(var.environment_prefix, "-", "_")}_audit_records"
}

resource "aws_iam_role" "audit_records" {
  assume_role_policy = data.aws_iam_policy_document.aws_glue_assume_role.json
  name               = "${var.environment_prefix}-audit-records"
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "audit_records" {
  role       = aws_iam_role.audit_records.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "audit_records" {
  name   = "${var.environment_prefix}-audit-records"
  policy = data.aws_iam_policy_document.audit_records.json
  role   = aws_iam_role.audit_records.id
}


data "aws_iam_policy_document" "audit_records" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:PutObject*",
      "s3:DeleteObject*",
    ]

    resources = [
      "${aws_s3_bucket.audit_records.arn}/*"
    ]

    sid = "AllowReadwriteAccessAuditRecordsBucket"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::echostream-artifacts-${local.current_region}/${lookup(local.artifacts["glue"], "audit_records_etl")}"
    ]

    sid = "GetGlueArtifacts"
  }
}

resource "aws_glue_crawler" "current_records" {
  description   = "Crawls over current audit records"
  database_name = aws_glue_catalog_database.audit_records.name
  name          = "current"
  role          = aws_iam_role.audit_records.arn

  s3_target {
    path = "s3://${aws_s3_bucket.audit_records.id}/current"
  }

  configuration = <<EOF
{
  "Version":1.0,
  "Grouping": {
    "TableGroupingPolicy": "CombineCompatibleSchemas"
  }
}
EOF

  tags = local.tags
}

resource "aws_glue_crawler" "historical_records" {
  description   = "Crawls over historical audit records"
  database_name = aws_glue_catalog_database.audit_records.name
  name          = "historical"
  role          = aws_iam_role.audit_records.arn

  s3_target {
    path = "s3://${aws_s3_bucket.audit_records.id}/historical"
  }

  configuration = <<EOF
{
  "Version":1.0,
  "Grouping": {
    "TableGroupingPolicy": "CombineCompatibleSchemas"
  }
}
EOF

  tags = local.tags
}

##############
## Glue Job ##
##############
resource "aws_glue_job" "audit_records" {
  command {
    script_location = "s3://echostream-artifacts-${local.current_region}/${lookup(local.artifacts["glue"], "audit_records_etl")}"
    python_version  = 3
  }

  default_arguments = {
    "--job-language"        = "python"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--bucket"              = aws_s3_bucket.audit_records.id
    "--database"            = aws_glue_catalog_database.audit_records.id
  }

  execution_property {
    max_concurrent_runs = 1
  }

  glue_version      = "2.0"
  max_retries       = 1
  timeout           = 2880
  name              = "${var.environment_prefix}-audit-records"
  number_of_workers = 2
  worker_type       = "G.1X"
  role_arn          = aws_iam_role.audit_records.arn
  tags              = local.tags
}
