resource "aws_bcmdataexports_export" "cost_and_usage" {
  depends_on = [aws_s3_bucket_policy.cost_and_usage]

  export {
    data_query {
      query_statement = <<-QUERY
      SELECT 
        bill_bill_type, bill_billing_entity, bill_billing_period_end_date, bill_billing_period_start_date, bill_invoice_id, bill_invoicing_entity, bill_payer_account_id,
        bill_payer_account_name, cost_category, discount, discount_bundled_discount, discount_total_discount, identity_line_item_id, identity_time_interval,
        line_item_availability_zone, line_item_blended_cost, line_item_blended_rate, line_item_currency_code, line_item_legal_entity, line_item_line_item_description,
        line_item_line_item_type, line_item_net_unblended_cost, line_item_net_unblended_rate, line_item_normalization_factor, line_item_normalized_usage_amount, line_item_operation,
        line_item_product_code, line_item_resource_id, line_item_tax_type, line_item_unblended_cost, line_item_unblended_rate, line_item_usage_account_id, line_item_usage_account_name,
        line_item_usage_amount, line_item_usage_end_date, line_item_usage_start_date, line_item_usage_type, pricing_currency, pricing_lease_contract_length, pricing_offering_class,
        pricing_public_on_demand_cost, pricing_public_on_demand_rate, pricing_purchase_option, pricing_rate_code, pricing_rate_id, pricing_term, pricing_unit, product, product_comment,
        product_fee_code, product_fee_description, product_from_location, product_from_location_type, product_from_region_code, product_instance_family, product_instance_type,
        product_instancesku, product_location, product_location_type, product_operation, product_pricing_unit, product_product_family, product_region_code, product_servicecode,
        product_sku, product_to_location, product_to_location_type, product_to_region_code, product_usagetype, reservation_amortized_upfront_cost_for_usage,
        reservation_amortized_upfront_fee_for_billing_period, reservation_availability_zone, reservation_effective_cost, reservation_end_time, reservation_modification_status,
        reservation_net_amortized_upfront_cost_for_usage, reservation_net_amortized_upfront_fee_for_billing_period, reservation_net_effective_cost, reservation_net_recurring_fee_for_usage,
        reservation_net_unused_amortized_upfront_fee_for_billing_period, reservation_net_unused_recurring_fee, reservation_net_upfront_value, reservation_normalized_units_per_reservation,
        reservation_number_of_reservations, reservation_recurring_fee_for_usage, reservation_reservation_a_r_n, reservation_start_time, reservation_subscription_id,
        reservation_total_reserved_normalized_units, reservation_total_reserved_units, reservation_units_per_reservation, reservation_unused_amortized_upfront_fee_for_billing_period,
        reservation_unused_normalized_unit_quantity, reservation_unused_quantity, reservation_unused_recurring_fee, reservation_upfront_value, resource_tags,
        savings_plan_amortized_upfront_commitment_for_billing_period, savings_plan_end_time, savings_plan_instance_type_family, savings_plan_net_amortized_upfront_commitment_for_billing_period,
        savings_plan_net_recurring_commitment_for_billing_period, savings_plan_net_savings_plan_effective_cost, savings_plan_offering_type, savings_plan_payment_option, savings_plan_purchase_term,
        savings_plan_recurring_commitment_for_billing_period, savings_plan_region, savings_plan_savings_plan_a_r_n, savings_plan_savings_plan_effective_cost, savings_plan_savings_plan_rate,
        savings_plan_start_time, savings_plan_total_commitment_to_date, savings_plan_used_commitment
      FROM COST_AND_USAGE_REPORT
      QUERY
      table_configurations = {
        COST_AND_USAGE_REPORT = {
          INCLUDE_MANUAL_DISCOUNT_COMPATIBILITY = "FALSE",
          INCLUDE_RESOURCES                     = "TRUE",
          INCLUDE_SPLIT_COST_ALLOCATION_DATA    = "FALSE",
          TIME_GRANULARITY                      = "MONTHLY",
        }
      }
    }

    description = "EchoStream Billing Exports"

    destination_configurations {
      s3_destination {
        s3_bucket = aws_s3_bucket.cost_and_usage.id

        s3_output_configurations {
          compression = "PARQUET"
          format      = "PARQUET"
          output_type = "CUSTOM"
          overwrite   = "OVERWRITE_REPORT"
        }

        s3_prefix = "exports"
        s3_region = aws_s3_bucket.cost_and_usage.region
      }
    }

    name = local.cost_and_usage_export_name

    refresh_cadence {
      frequency = "SYNCHRONOUS"
    }
  }
}

resource "aws_s3_bucket" "cost_and_usage" {
  bucket = "${var.resource_prefix}-cost-and-usage"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_acl" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    id     = "cost-and-usage-cleanup"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_logging" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id

  target_bucket = local.log_bucket
  target_prefix = "${var.resource_prefix}-cost-and-usage/"
}

data "aws_iam_policy_document" "cost_and_usage" {
  statement {
    actions = [
      "s3:GetBucketPolicy",
      "s3:PutObject"
    ]
    condition {
      test = "StringLike"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
      variable = "aws:SourceAccount"
    }
    condition {
      test = "StringLike"
      values = [
        "arn:aws:bcm-data-exports:us-east-1:${data.aws_caller_identity.current.account_id}:export/*",
        "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*",
      ]
      variable = "aws:SourceArn"
    }
    effect = "Allow"
    principals {
      identifiers = [
        "bcm-data-exports.amazonaws.com",
        "billingreports.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      aws_s3_bucket.cost_and_usage.arn,
      "${aws_s3_bucket.cost_and_usage.arn}/*",
    ]
    sid = "CostAndUsageReports"
  }
}

resource "aws_s3_bucket_policy" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  policy = data.aws_iam_policy_document.cost_and_usage.json
}

resource "aws_s3_bucket_public_access_block" "cost_and_usage" {
  bucket                  = aws_s3_bucket.cost_and_usage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  versioning_configuration {
    status = "Enabled"
  }
}

## CUR Report Definition ##
/*
resource "aws_cur_report_definition" "cost_and_usage" {
  depends_on                 = [aws_s3_bucket_policy.cost_and_usage]
  additional_schema_elements = ["RESOURCES"]
  compression                = "Parquet"
  format                     = "Parquet"
  refresh_closed_reports     = true
  report_name                = "CostAndUsage"
  report_versioning          = "OVERWRITE_REPORT"
  s3_prefix                  = "reports"
  # Can't leave S3 prefix empty if Definition is integrated with Athena
  # If s3_prefix is empty, AWS is making ReportPathPrefix = /<report_name>
  # so final reports are put under /<report_name>/<report_name>
  # Example, lets say our report-name = "CostAndUsage". The S3 path would be s3://<bucket-name>//CostAndUsage/CostAndUsage/<reports>
  # better to include some prefix, to make it look cleaner (avoids leading slash)
  # for e.g if prefix is set to 'echo'. The s3 path would look like s3://<bucket-name>/echo/CostAndUsage/CostAndUsage/<reports>
  s3_bucket = aws_s3_bucket.cost_and_usage.id
  s3_region = data.aws_region.current.name
  time_unit = "DAILY"

  provider = aws.us-east-1
}
*/
