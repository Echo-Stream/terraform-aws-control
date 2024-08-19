from datetime import datetime, timezone
import json
from logging import ERROR, INFO, getLogger
from os import environ

import awswrangler
import boto3
from botocore.config import Config
from dateutil.relativedelta import relativedelta

getLogger().setLevel(INFO)
getLogger("boto3").setLevel(ERROR)
getLogger("botocore").setLevel(ERROR)

AUDIT_COLSOLIDATOR_TOPIC_ARN = "${audit_consolidator_topic_arn}"
AWS_REGION = environ.get("AWS_REGION") or environ["AWS_DEFAULT_REGION"]
TENANT_REGIONS: list[str] = json.loads("${tenant_regions}")


def consolidate_audits(bucket: str, region: str) -> None:
    now = datetime.now(tz=timezone.utc) - relativedelta(days=1)
    boto3_session = boto3.Session(region_name=region)
    if daily_files := awswrangler.s3.list_objects(
        boto3_session=boto3_session,
        path=f"s3://{bucket}/audit-records/records/year={now.year:04d}/month={now.month:02d}/day={now.day:02d}/",
        suffix=".gz",
    ):
        audit_records = awswrangler.s3.read_json(
            boto3_session=boto3_session,
            compression="gzip",
            lines=True,
            path=daily_files,
            use_threads=True,
        )
        awswrangler.s3.to_parquet(
            boto3_session=boto3_session,
            compression="snappy",
            df=audit_records,
            path=f"s3://{bucket}/audit-records/archive/year={now.year:04d}/month={now.month:02d}/{now.day:02d}.snappy.parquet",
            use_threads=True,
        )
        awswrangler.s3.delete_objects(boto3_session=boto3_session, path=daily_files)


def find_tenant_buckets(region: str) -> None:
    s3_client = boto3.client(
        "s3",
        config=Config(retries=dict(mode="standard"), signature_version="s3v4"),
        region_name=region,
    )
    sns_client = boto3.client(
        "sns", config=Config(retries=dict(mode="standard")), region_name=AWS_REGION
    )
    list_buckets_params = dict()
    while True:
        response = s3_client.list_buckets(**list_buckets_params)
        for bucket in response["Buckets"]:
            if bucket["Name"].startswith("tenant-"):
                sns_client.publish(
                    Message=json.dumps(
                        dict(
                            bucket=bucket["Name"],
                            region=region,
                        ),
                        separators=(",", ":"),
                    ),
                    TopicArn=AUDIT_COLSOLIDATOR_TOPIC_ARN,
                )
        if continuation_token := response.get("ContinuationToken"):
            list_buckets_params["ContinuationToken"] = continuation_token
            continue
        return


def lambda_handler(event, _) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    if (
        isinstance(event, dict)
        and (records := event.get("Records"))
        and records[0].get("EventSource") == "aws:sns"
    ):
        for record in records:
            message = json.loads(record["Sns"]["Message"])
            getLogger().info(f"Consolidate audits:\n{json.dumps(message, indent=2)}")
            consolidate_audits(**message)
    else:
        for region in TENANT_REGIONS:
            find_tenant_buckets(region)
