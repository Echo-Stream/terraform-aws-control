import datetime
import json
from logging import ERROR, getLogger

import awswrangler
import boto3
import pandas


getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

S3_PARQUET_PATH = (
    "s3://${cost_and_usage_bucket}/managed-instances/managed-instances.snappy.parquet"
)


def lambda_handler(event, _) -> None:
    dataframe: pandas.DataFrame = pandas.DataFrame()
    try:
        dataframe = awswrangler.s3.read_parquet(path=S3_PARQUET_PATH)
    except awswrangler.exceptions.NoFilesFound:
        getLogger().info("Initial file creation")

    messages: list[dict[str, str]] = list()
    for record in event["Records"]:
        message = json.loads(record["body"])
        message["timestamp"] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        messages.append(message)
        getLogger().debug(f"message {message}")

    awswrangler.s3.to_parquet(
        df=pandas.concat(
            objs=[dataframe, pandas.DataFrame.from_records(messages)],
            ignore_index=True,
        )
        .sort_values(by=["id", "timestamp"], ignore_index=True)
        .drop_duplicates(subset="id", ignore_index=True),
        compression="snappy",
        path=S3_PARQUET_PATH,
    )
    getLogger().info(
        f'Managed instances {[message["id"] for message in messages]} are successfully written into {S3_PARQUET_PATH}'
    )

    response = boto3.client("lambda").invoke(
        FunctionName="${registration_function_arn}",
        InvocationType="RequestResponse",
        Payload=json.dumps(messages, separators=(",", ":")).encode(),
    )
    if response["StatusCode"] != 200:
        raise Exception(response["FunctionError"])
