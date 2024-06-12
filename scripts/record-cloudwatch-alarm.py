import json
from datetime import datetime
from logging import ERROR, INFO, getLogger
from typing import cast

import awswrangler
import pandas

getLogger().setLevel(INFO)
getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

S3_PARQUET_PATH = "s3://${cost_and_usage_bucket}/alarms/alarms.snappy.parquet"


def lambda_handler(event, _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    try:
        alarms = awswrangler.s3.read_parquet(path=S3_PARQUET_PATH)
    except awswrangler.exceptions.NoFilesFound:
        getLogger().info("Initial file creation")
        alarms = pandas.DataFrame()
    for record in event["Records"]:
        message = json.loads(record["body"])
        identity = message["identity"]
        getLogger().info(f"Alarm update:\n{json.dumps(message, indent=2)}")
        start = pandas.Timestamp(datetime.fromisoformat(message["datetime"]))
        count = 0
        if not alarms.empty:
            index = cast(
                pandas.DataFrame,
                alarms[(alarms["identity"] == identity) & (alarms["end"].isna())],
            ).index
            if index.size == 1:
                alarms.at[index[0], "end"] = start
                count = int(alarms.at[index[0], "count"])
            elif not index.empty:
                getLogger().error(f"Multiple active alarm records for {identity}")
                continue
        if (count := count + int(message["increment"])) > 0:
            alarms = pandas.concat(
                [
                    alarms,
                    pandas.DataFrame(
                        [
                            dict(
                                count=count,
                                end=pandas.Timestamp(None),
                                identity=identity,
                                start=start,
                            )
                        ]
                    ),
                ],
                ignore_index=True,
            )

    if not alarms.empty:
        awswrangler.s3.to_parquet(
            df=alarms,
            compression="snappy",
            path=S3_PARQUET_PATH,
        )
    getLogger().info(f'Recorded {len(event["Records"])} Alarms')
