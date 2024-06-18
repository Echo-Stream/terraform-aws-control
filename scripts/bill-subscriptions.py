from concurrent.futures import Future, ThreadPoolExecutor
from datetime import datetime, timezone
import json
from logging import ERROR, INFO, getLogger
import math
from os import environ
from random import randint
from time import sleep
from typing import Any, Dict, Generator, List, Tuple

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
COST_AND_USAGE_BUCKET = "${cost_and_usage_bucket}"
PADDLE_API_KEY: str = None
PADDLE_BASE_URL: str = "${paddle_base_url}"
USAGE_PRICE_ID = "${usage_price_id}"


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
    identity: str, month: int, subscriptionid: str, year: int
) -> None:
    total = math.ceil(
        float(
            boto3.client(
                "s3",
                config=Config(retries=dict(mode="standard")),
                region_name=AWS_REGION,
            ).head_object(
                Bucket=COST_AND_USAGE_BUCKET,
                Key=f"usages/IDENTITY={identity}/YEAR={year}/MONTH={month}/usage.csv",
            )[
                "Metadata"
            ][
                "total"
            ]
        )
    )
    with requests.post(
        f"{PADDLE_BASE_URL}/subscriptions/{subscriptionid}/charge",
        headers=dict(
            Accept="application/json",
            Authorization=f"Bearer {paddle_api_key()}",
        ),
        json=dict(
            effective_from="next_billing_period",
            items=[
                dict(
                    quantity=total,
                    price=USAGE_PRICE_ID,
                )
            ],
        ),
    ) as response:
        response.raise_for_status()
    getLogger().info(
        f"Billed subscription {subscriptionid} for ${total:.2f} for Tenant {identity}"
    )


def bill_subscriptions(
    subscriptions: List[Tuple[str, int, str, int]], count: int = 0
) -> None:
    with ThreadPoolExecutor(max_workers=20) as executor:
        futures: list[Future] = list()
        for subscription in subscriptions:
            future = executor.submit(
                bill_subscription,
                *subscription,
            )
            future.subscription = subscription
            futures.append(future)
        subscriptions.clear()
        for future in futures:
            if future.exception():
                getLogger().error(
                    f"Falied to bill subscription {future.subscription[2]}",
                    exc_info=future.exception(),
                )
                subscriptions.append(future.subscription)
        if subscriptions and count < 2:
            sleep(randint(5, 10))
            bill_subscriptions(subscriptions, count + 1)


def lambda_handler(event: Dict[str, Any], _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    now = datetime.now(tz=timezone.utc) - relativedelta(months=1)
    subscriptions = [
        dict(
            identity=record["identity"],
            month=now.month,
            subscriptionid=record["subscriptionid"],
            year=now.year,
        )
        for record in execute_query(
            f"""
        SELECT DISTINCT tenants.identity, tenants.subscriptionid
        FROM costandusagedata JOIN tenants 
            ON costandusagedata.resource_tags['user_identity']=tenants.identity
        WHERE costandusagedata.resource_tags['user_identity'] IS NOT NULL 
            AND costandusagedata.billing_period='{now.year:04d}-{now.month:02d}' 
            AND tenants.subscriptionid IS NOT NULL
        """
        )
    ]
    bill_subscriptions(subscriptions)
    getLogger().info(f"Billed {len(subscriptions)} subscriptions")
