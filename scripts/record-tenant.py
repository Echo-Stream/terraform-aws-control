import json
from datetime import timezone
from logging import ERROR, INFO, getLogger

import awswrangler
import pandas

getLogger().setLevel(INFO)
getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

S3_PARQUET_PATH = "s3://${cost_and_usage_bucket}/tenants/tenants.snappy.parquet"


def lambda_handler(event, _) -> None:
    dataframe: pandas.DataFrame = pandas.DataFrame()
    try:
        dataframe = awswrangler.s3.read_parquet(path=S3_PARQUET_PATH)
    except awswrangler.exceptions.NoFilesFound:
        getLogger().info("Initial file creation")

    messages: list[dict[str, str]] = list()
    for record in event["Records"]:
        message = json.loads(record["body"])
        message["created"] = pandas.Timestamp(message["created"])
        message["updated"] = pandas.Timestamp.now(tz=timezone.utc)
        messages.append(message)
        getLogger().debug(f"Tenant:\n{json.dumps(message, indent=2)}")

    awswrangler.s3.to_parquet(
        df=dataframe.merge(
            pandas.DataFrame.from_records(messages).drop_duplicates(
                ignore_index=True, keep="last", subset="identity"
            ),
            how="outer",
            on="identity",
        )
        .groupby(lambda x: x.split("_")[0], axis=1)
        .last(),
        compression="snappy",
        path=S3_PARQUET_PATH,
    )
    getLogger().info(f"Recorded Tenants:\n{json.dumps(messages, indent=2)}")
