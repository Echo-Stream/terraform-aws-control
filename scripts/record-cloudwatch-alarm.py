import json
from datetime import datetime
from logging import ERROR, INFO, getLogger
from typing import cast

import awswrangler
import pandas

getLogger().setLevel(INFO)
getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

S3_PARQUET_BASE_PATH = "s3://${cost_and_usage_bucket}/alarms"


def lambda_handler(event, _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    tenant_alarms: dict[str, pandas.DataFrame] = dict()
    for record in event["Records"]:
        message = json.loads(record["body"])
        identity = message["identity"]
        getLogger().info(f"Alarm update:\n{json.dumps(message, indent=2)}")
        if not (alarms := tenant_alarms.get(identity)):
            try:
                alarms = awswrangler.s3.read_parquet(
                    path=f"{S3_PARQUET_BASE_PATH}/IDENTITY={identity}/alarms.snappy.parquet"
                )
            except awswrangler.exceptions.NoFilesFound:
                getLogger().info("Initial file creation")
                alarms = pandas.DataFrame()
            tenant_alarms[identity] = alarms
        start = pandas.Timestamp(datetime.fromisoformat(message["datetime"]))
        count = 0
        index = cast(
            pandas.DataFrame,
            alarms[(alarms["identity"] == identity) & (alarms["end"].isna())],
        ).index
        if index.size == 1:
            alarms.at[index[0], "end"] = start
            count = alarms.at[index[0], "count"]
        elif not index.empty:
            getLogger().error(f"Multiple active alarm records for {identity}")
            continue
        if (count := count + message["increment"]) > 0:
            alarms = pandas.concat(
                [
                    alarms,
                    pandas.DataFrame(
                        [
                            dict(
                                count=count,
                                end=None,
                                start=start,
                            )
                        ]
                    ),
                ],
                ignore_index=True,
            )

    for identity, alarms in tenant_alarms.items():
        if not alarms.empty:
            awswrangler.s3.to_parquet(
                df=alarms,
                compression="snappy",
                path=f"{S3_PARQUET_BASE_PATH}/IDENTITY={identity}/alarms",
            )
    getLogger().info(f'Recorded {len(event["Records"])} Alarms')
