import json
from logging import ERROR, INFO, getLogger
from typing import Union

import awswrangler
import pandas

getLogger().setLevel(INFO)
getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

S3_PARQUET_PATH = "s3://${cost_and_usage_bucket}/tenants/tenants.snappy.parquet"


def lambda_handler(event, _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    messages: list[dict[str, Union[str, pandas.Timestamp]]] = list()
    for record in event["Records"]:
        message = json.loads(record["body"])
        getLogger().info(f"Tenant:\n{json.dumps(message, indent=2)}")
        message["created"] = pandas.Timestamp(message["created"])
        messages.append(message)

    if messages:
        tenants = pandas.DataFrame.from_records(messages).drop_duplicates(
            ignore_index=True, keep="last", subset="identity"
        )
        try:
            tenants = (
                awswrangler.s3.read_parquet(path=S3_PARQUET_PATH)
                .merge(
                    tenants,
                    how="outer",
                    on="identity",
                )
                .groupby(lambda x: x.split("_")[0], axis=1)
                .last()
            )
        except awswrangler.exceptions.NoFilesFound:
            getLogger().info("Initial file creation")

        awswrangler.s3.to_parquet(
            df=tenants,
            compression="snappy",
            path=S3_PARQUET_PATH,
        )
    getLogger().info(f"Recorded {len(messages)} Tenants")
