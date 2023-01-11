import json
from copy import deepcopy
from datetime import timezone
from logging import ERROR, INFO, getLogger

import awswrangler
import pandas

getLogger().setLevel(INFO)
getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

S3_PARQUET_PATH = "s3://${cost_and_usage_bucket}/tenants/tenants.snappy.parquet"


def lambda_handler(event, _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    if not (isinstance(event, dict) and "identity" in event):
        return
    tenant: dict[str, str] = deepcopy(event)
    dataframe: pandas.DataFrame = pandas.DataFrame()
    try:
        dataframe = awswrangler.s3.read_parquet(path=S3_PARQUET_PATH)
    except awswrangler.exceptions.NoFilesFound:
        getLogger().info("Initial file creation")
    tenant["created"] = pandas.Timestamp(tenant["created"])
    tenant["updated"] = pandas.Timestamp.now(tz=timezone.utc)

    awswrangler.s3.to_parquet(
        df=dataframe.merge(
            pandas.DataFrame.from_records([tenant]),
            how="outer",
            on="identity",
        )
        .groupby(lambda x: x.split("_")[0], axis=1)
        .last(),
        compression="snappy",
        path=S3_PARQUET_PATH,
    )
    getLogger().info(f"Recorded Tenant:\n{json.dumps(tenant, indent=2)}")
