import json
import math
from datetime import datetime, timezone
from http import HTTPStatus
from logging import ERROR, INFO, getLogger
from os import environ
from random import randint
from time import sleep
from typing import Any, Dict, Generator

import boto3
import requests
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
BILL_SUBSCRIPTION_TOPIC_ARN = "${bill_subscription_topic_arn}"
COST_AND_USAGE_BUCKET = "${cost_and_usage_bucket}"
PADDLE_API_KEY: str = None
PADDLE_BASE_URL = "${paddle_base_url}"
PADDLE_USAGE_PRICE_AMOUNT = int("${paddle_usage_price_amount}")
USAGE_PRODUCT_ID = "${usage_product_id}"
USAGE_MULTIPLE = float("${usage_multiple}")


def paddle_api_key() -> str:
    global PADDLE_API_KEY
    if not PADDLE_API_KEY:
        PADDLE_API_KEY = boto3.client("secretsmanager").get_secret_value(
            SecretId="${paddle_api_key_secret_arn}"
        )["SecretString"]
    return PADDLE_API_KEY


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


def bill_subscription(
    identity: str, month: int, subscriptionid: str, tenant: str, year: int
) -> None:
    total = math.ceil(
        float(
            boto3.client(
                "s3",
                config=Config(retries=dict(mode="standard")),
                region_name=AWS_REGION,
            ).head_object(
                Bucket=COST_AND_USAGE_BUCKET,
                Key=f"usages/IDENTITY={identity}/YEAR={year:04d}/MONTH={month:02d}/usage.csv",
            )[
                "Metadata"
            ][
                "total"
            ]
        )
        * USAGE_MULTIPLE
    ) - int(3000 / PADDLE_USAGE_PRICE_AMOUNT)
    if total > 0:
        with requests.post(
            f"{PADDLE_BASE_URL}/subscriptions/{subscriptionid}/charge",
            headers=dict(
                Accept="application/json",
                Authorization=f"Bearer {paddle_api_key()}",
            ),
            json=dict(
                effective_from="immediately",
                items=[
                    dict(
                        price=dict(
                            description=f"Additional usage for Tenant {tenant}",
                            name=f"{tenant[:40]} ({year}-{month:02d})",
                            product_id=USAGE_PRODUCT_ID,
                            quantity=dict(
                                maximum=total,
                                minimum=1,
                            ),
                            tax_mode="external",
                            unit_price=dict(
                                amount=str(PADDLE_USAGE_PRICE_AMOUNT),
                                currency_code="USD",
                            ),
                        ),
                        quantity=total,
                    )
                ],
                on_payment_failure="apply_change",
            ),
        ) as response:
            try:
                response.raise_for_status()
            except requests.exceptions.HTTPError as e:
                if (
                    response.status_code == HTTPStatus.BAD_REQUEST
                    and (error := response.json().get("error"))
                    and error.get("code") == "subscription_update_when_canceled"
                ):
                    getLogger().critical(
                        f"Subscription {subscriptionid} is cancelled, skipping billing"
                    )
                    return
                if response.status_code == HTTPStatus.TOO_MANY_REQUESTS:
                    sleep(float(response.headers.get("Retry-After") or 60))
                    raise Exception(
                        f"Throttled for subscription {subscriptionid}, retrying"
                    ) from e
                raise Exception(
                    f"Paddle error for subscription {subscriptionid}, retrying:\n{json.dumps(response.json(), indent=2)}"
                ) from e
    getLogger().info(
        f"Billed subscription {subscriptionid} for {total} usages for Tenant {identity}"
    )


def bill_subscriptions() -> None:
    now = datetime.now(tz=timezone.utc) - relativedelta(months=1)
    count = 0
    sns_client = boto3.client(
        "sns", config=Config(retries=dict(mode="standard")), region_name=AWS_REGION
    )
    for record in execute_query(
        f"""
    SELECT DISTINCT tenants.identity, tenants.name, tenants.subscriptionid
    FROM costandusagedata JOIN tenants
        ON costandusagedata.resource_tags['user_identity']=tenants.identity
    WHERE costandusagedata.resource_tags['user_identity'] IS NOT NULL
        AND costandusagedata.billing_period='{now.year:04d}-{now.month:02d}'
        AND tenants.subscriptionid IS NOT NULL
    """
    ):
        sns_client.publish(
            Message=json.dumps(
                dict(
                    identity=str(record["identity"]),
                    month=now.month,
                    subscriptionid=str(record["subscriptionid"]),
                    tenant=str(record["name"]),
                    year=now.year,
                ),
                separators=(",", ":"),
            ),
            TopicArn=BILL_SUBSCRIPTION_TOPIC_ARN,
        )
        count += 1
    getLogger().info(f"Initiated billing for {count} subscriptions")


def lambda_handler(event: Dict[str, Any], _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    if (
        isinstance(event, dict)
        and (records := event.get("Records"))
        and records[0].get("EventSource") == "aws:sns"
    ):
        for record in records:
            message = json.loads(record["Sns"]["Message"])
            getLogger().info(f"Bill subscription:\n{json.dumps(message, indent=2)}")
            bill_subscription(**message)
    else:
        bill_subscriptions()
