import json
from concurrent.futures import ThreadPoolExecutor, as_completed
from csv import DictWriter
from datetime import datetime, timezone
from io import BytesIO, TextIOWrapper
from logging import ERROR, INFO, getLogger
from os import environ
from random import randint
from time import sleep
from typing import Any, Dict, Generator

import boto3
from botocore.config import Config
from dateutil.relativedelta import relativedelta

getLogger().setLevel(INFO)
getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

AWS_REGION = environ.get("AWS_REGION") or environ["AWS_DEFAULT_REGION"]
ATHENA_CLIENT = boto3.client(
    "athena", config=Config(retries=dict(mode="standard")), region_name=AWS_REGION
)
ATHENA_WORKGROUP = "${athena_workgroup}"
BILLING_DATABASE = "${billing_database}"
COST_AND_USAGE_BUCKET = "${cost_and_usage_bucket}"
COMPUTE_USAGE_TOPIC_ARN = "${compute_usage_topic_arn}"
SYSTEM_ALARM_COUNT = "${system_alarm_count}"


def execute_query(query: str) -> Generator[dict[str, str], None, None]:
    sleep(randint(1, 5))
    query_execution_id = ATHENA_CLIENT.start_query_execution(
        QueryExecutionContext=dict(Database=BILLING_DATABASE),
        QueryString=query,
        WorkGroup=ATHENA_WORKGROUP,
    )["QueryExecutionId"]
    while True:
        status = ATHENA_CLIENT.get_query_execution(QueryExecutionId=query_execution_id)[
            "QueryExecution"
        ]["Status"]
        if status["State"] == "SUCCEEDED":
            break
        elif status["State"] in ("FAILED", "CANCELLED"):
            getLogger().error(
                f'Athena error:\n{json.dumps(status.get("AthenaError"), indent=2)}'
            )
            raise RuntimeError(
                f'Athena error: {status.get("AthenaError", dict()).get("ErrorMessage")}'
            )
        else:
            sleep_time = randint(1, 10)
            getLogger().info(
                f"Athena query status: {status['State']}, sleeping {sleep_time} seconds"
            )
            sleep(sleep_time)
    sleep(randint(1, 5))
    query_results_params = dict(QueryExecutionId=query_execution_id)
    while True:
        results = ATHENA_CLIENT.get_query_results(**query_results_params)
        column_info = results["ResultSet"]["ResultSetMetadata"]["ColumnInfo"]
        first_row = True
        for row in results["ResultSet"]["Rows"]:
            if first_row:
                first_row = False
                continue
            yield {
                column["Name"]: row["Data"][i]["VarCharValue"]
                for i, column in enumerate(column_info)
            }
        if "NextToken" in results:
            query_results_params["NextToken"] = results["NextToken"]
            sleep(randint(1, 3))
        else:
            break


def compute_tenant(identity: str, month: int, year: int) -> None:

    def get_alarm_line_items() -> Generator[dict[str, str], None, None]:
        period_start = datetime.now(tz=timezone.utc).replace(
            day=1, hour=0, minute=0, second=0, microsecond=0
        )
        start = period_start.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
        end = (period_start + relativedelta(months=+1, microseconds=-1)).strftime(
            "%Y-%m-%d %H:%M:%S.%f"
        )[:-3]
        yield from execute_query(
            f"""
            WITH
                tenant_alarms AS (
                    SELECT 
                        "count",
                        identity,
                        CASE
                            WHEN "start" < timestamp '{start}' THEN timestamp '{start}'
                            ELSE "start"
                        END AS "start",
                        CASE
                            WHEN "end" > timestamp '{end}' THEN timestamp '{end}'
                            WHEN "end" IS NULL THEN current_timestamp
                            ELSE "end"
                        END AS "end"
                    FROM alarms
                    WHERE 
                        "start" < timestamp '{end}' 
                        AND ("end" > timestamp '{start}' OR "end" IS NULL)
                    UNION ALL
                    SELECT
                        {SYSTEM_ALARM_COUNT} as "count",
                        'SYSTEM' AS identity,
                        timestamp '{start}' AS "start",
                        current_timestamp AS "end"
                ),
                total_duration AS (
                    SELECT
                        sum("count" * date_diff('second', "start", "end")) AS duration
                    FROM tenant_alarms
                ),
                tenant_ratios AS (
                    SELECT
                        identity,
                        cast(sum("count" * date_diff('second', "start", "end")) AS double) / cast(duration AS double) AS ratio
                    FROM tenant_alarms, total_duration
                    GROUP BY identity, duration
                ),
                alarm_usage AS (
                    SELECT 
                        sum(line_item_blended_cost) AS line_item_blended_cost, 
                        sum(line_item_usage_amount) AS line_item_usage_amount
                    FROM costandusagedata 
                    WHERE 
                        line_item_product_code='AmazonCloudWatch' 
                        AND regexp_like(line_item_usage_type, '.*:AlarmMonitorUsage') 
                        AND billing_period='{year:04d}-{month:02d}' 
                        AND line_item_blended_rate IS NOT NULL
                )
            SELECT 
                line_item_blended_cost * ratio AS line_item_blended_cost,
                line_item_blended_cost / line_item_usage_amount AS line_item_blended_rate,
                line_item_usage_amount * ratio AS line_item_usage_amount,
                'AlarmMonitorUsage' AS line_item_usage_type,
                'AmazonCloudWatch' AS line_item_product_code
            FROM tenant_ratios, alarm_usage
            WHERE identity='{identity}'
            """
        )

    def get_tenant_line_items() -> Generator[dict[str, str], None, None]:
        yield from execute_query(
            f"""
            SELECT
                SUM(line_item_blended_cost) as line_item_blended_cost,
                line_item_blended_rate,
                SUM(line_item_usage_amount) as line_item_usage_amount,
                line_item_usage_type,
                line_item_product_code
            FROM costandusagedata
            WHERE
                billing_period='{year:04d}-{month:02d}' AND
                resource_tags['user_identity']='{identity}'
            GROUP BY
                line_item_blended_rate,
                line_item_usage_type,
                line_item_product_code
        """
        )

    def get_managed_instance_line_items() -> Generator[dict[str, str], None, None]:
        yield from execute_query(
            f"""
            SELECT
                SUM(line_item_blended_cost) as line_item_blended_cost,
                line_item_blended_rate,
                SUM(line_item_usage_amount) as line_item_usage_amount,
                line_item_usage_type,
                line_item_product_code
            FROM costandusagedata JOIN managedinstances
                ON costandusagedata.line_item_resource_id=managedinstances.id
            WHERE
                billing_period='{year:04d}-{month:02d}' AND
                identity='{identity}'
            GROUP BY
                line_item_blended_rate,
                line_item_usage_type,
                line_item_product_code
        """
        )

    total = 0.0
    with BytesIO() as body:
        with TextIOWrapper(body, write_through=True) as text_body:
            with ThreadPoolExecutor() as executor:
                writer: DictWriter = None
                for future in as_completed(
                    [
                        executor.submit(get_alarm_line_items),
                        executor.submit(get_tenant_line_items),
                        executor.submit(get_managed_instance_line_items),
                    ]
                ):
                    for line_item in future.result():
                        total += float(line_item["line_item_blended_cost"])
                        if not writer:
                            writer = DictWriter(text_body, fieldnames=line_item.keys())
                            writer.writeheader()
                        writer.writerow(line_item)
            body.seek(0)
            boto3.client(
                "s3",
                config=Config(retries=dict(mode="standard")),
                region_name=AWS_REGION,
            ).put_object(
                Body=body,
                Bucket=COST_AND_USAGE_BUCKET,
                Key=f"usages/IDENTITY={identity}/YEAR={year}/MONTH={month}/usage.csv",
                Metadata=dict(total=str(total)),
            )


def compute_tenants() -> None:
    now = datetime.now(tz=timezone.utc)
    billing_periods: list[tuple[int, int]] = [(now.year, now.month)]
    if now.day <= 3 and now.hour < 11:
        now -= relativedelta(months=1)
        billing_periods.append((now.year, now.month))
    sns_client = boto3.client(
        "sns", config=Config(retries=dict(mode="standard")), region_name=AWS_REGION
    )
    for year, month in billing_periods:
        for record in execute_query(
            f"""
            SELECT DISTINCT resource_tags['user_identity'] AS identity
            FROM costandusagedata
            WHERE resource_tags['user_identity'] IS NOT NULL AND billing_period='{year:04d}-{month:02d}'
            """
        ):
            sns_client.publish(
                Message=json.dumps(
                    dict(identity=record["identity"], month=month, year=year),
                    separators=(",", ":"),
                ),
                TopicArn=COMPUTE_USAGE_TOPIC_ARN,
            )


def lambda_handler(event: Dict[str, Any], _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    if (
        isinstance(event, dict)
        and (records := event.get("Records"))
        and records[0].get("EventSource") == "aws:sns"
    ):
        for record in records:
            message = json.loads(record["Sns"]["Message"])
            getLogger().info(f"Compute usage:\n{json.dumps(message, indent=2)}")
            compute_tenant(**message)
    else:
        compute_tenants()
