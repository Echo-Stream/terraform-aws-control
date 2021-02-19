####################################################
### Audit Records Glue Catalog DB/Tables/Crawler ###
####################################################
resource "aws_glue_catalog_database" "audit_records" {
  description = "Audit Records"
  name        = "${replace(var.resource_prefix, "-", "_")}_audit_records"
}

resource "aws_iam_role" "audit_records" {
  assume_role_policy = data.aws_iam_policy_document.aws_glue_assume_role.json
  name               = "${var.resource_prefix}-audit-records"
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "audit_records" {
  role       = aws_iam_role.audit_records.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "audit_records" {
  name   = "${var.resource_prefix}-audit-records"
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
      "arn:aws:s3:::echostream-artifacts-${local.current_region}/${lookup(local.artifacts["glue"], "audit_records_etl")}",
      "arn:aws:s3:::echostream-artifacts-us-east-2/${lookup(local.artifacts["glue"], "audit_records_etl")}",
      "arn:aws:s3:::echostream-artifacts-us-west-2/${lookup(local.artifacts["glue"], "audit_records_etl")}",
    ]

    sid = "GetGlueArtifacts"
  }
}

resource "aws_glue_crawler" "current_records" {
  description   = "Crawls over current audit records"
  database_name = aws_glue_catalog_database.audit_records.name
  name          = "${var.resource_prefix}-current"
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
  name          = "${var.resource_prefix}-historical"
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
  description = "Extracts audit records and partitions them by tenant into historical table at the end of every month"

  command {
    script_location = "s3://echostream-artifacts-${local.current_region}/${lookup(local.artifacts["glue"], "audit_records_etl")}"
    python_version  = 3
  }

  default_arguments = {
    "--job-language"        = "python"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--bucket"              = aws_s3_bucket.audit_records.id
    "--database"            = aws_glue_catalog_database.audit_records.name
  }

  execution_property {
    max_concurrent_runs = 1
  }

  glue_version      = "2.0"
  max_retries       = 1
  timeout           = 2880
  name              = "${var.resource_prefix}-audit-records"
  number_of_workers = 2
  worker_type       = "G.1X"
  role_arn          = aws_iam_role.audit_records.arn
  tags              = local.tags
}

###################
## Glue WorkFlow ##
###################
resource "aws_glue_workflow" "audit_records" {
  name        = "${var.resource_prefix}-audit-records"
  description = "Extracts audit records and partitions them by tenant into historical table at the end of every month"
  tags        = local.tags
}

resource "aws_glue_trigger" "audit_records_start" {
  name          = "${var.resource_prefix}-audit-records-start"
  description   = "Triggers Audit records ETL Job on First of every month at 12:30AM"
  workflow_name = aws_glue_workflow.audit_records.name

  schedule = "cron(30 0 1 * ? *)"
  type     = "SCHEDULED"

  actions {
    job_name = aws_glue_job.audit_records.name
  }

  tags = local.tags
}

resource "aws_glue_trigger" "audit_records_end" {
  name          = "${var.resource_prefix}-audit-records-end"
  description   = "Triggers Current and Historical Glue Crawlers on successful ETL job completion"
  workflow_name = aws_glue_workflow.audit_records.name
  type          = "CONDITIONAL"

  predicate {
    conditions {
      job_name = aws_glue_job.audit_records.name
      state    = "SUCCEEDED"
    }
  }

  actions {
    crawler_name = aws_glue_crawler.current_records.id
  }

  actions {
    crawler_name = aws_glue_crawler.historical_records.id
  }

  tags = local.tags
}