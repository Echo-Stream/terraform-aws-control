import json
from copy import deepcopy
from datetime import timezone
from logging import ERROR, INFO, getLogger
from typing import Union

import awswrangler
import boto3
import pandas

getLogger().setLevel(INFO)
getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

S3_PARQUET_PATH = (
    "s3://${cost_and_usage_bucket}/managed-instances/managed-instances.snappy.parquet"
)


def lambda_handler(event, _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    messages: list[dict[str, str]] = list()
    instances: list[dict[str, Union[str, pandas.Timestamp]]] = list()
    for record in event["Records"]:
        message = json.loads(record["body"])
        getLogger().info(f"ManagedInstance:\n{json.dumps(message, indent=2)}")
        messages.append(message)
        instance = deepcopy(message)
        instance["registration"] = pandas.Timestamp.now(tz=timezone.utc)
        instances.append(instance)
    if instances:
        managed_instances = pandas.DataFrame.from_records(instances).drop_duplicates(
            ignore_index=True,
            subset="id",
        )
        try:
            managed_instances = (
                awswrangler.s3.read_parquet(path=S3_PARQUET_PATH)
                .merge(
                    managed_instances,
                    how="outer",
                    on="identity",
                )
                .groupby(lambda x: x.split("_")[0], axis=1)
                .last()
            )
        except awswrangler.exceptions.NoFilesFound:
            getLogger().info("Initial file creation")

        awswrangler.s3.to_parquet(
            compression="snappy",
            df=managed_instances,
            path=S3_PARQUET_PATH,
        )
    getLogger().info(f"Recorded {len(instances)} Managed Instances")

    if messages:
        boto3.client("lambda").invoke(
            FunctionName="${registration_function_arn}",
            InvocationType="Event",
            Payload=json.dumps(messages, separators=(",", ":")).encode(),
        )
