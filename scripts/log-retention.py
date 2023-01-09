from logging import INFO, getLogger
from typing import TYPE_CHECKING, Generator

import boto3

getLogger().setLevel(INFO)

if TYPE_CHECKING:
    from mypy_boto3_logs.type_defs import LogGroupTypeDef
else:
    LogGroupTypeDef = dict

client = boto3.client("logs")


def lambda_handler(event, context):
    for log_group in log_groups():
        if log_group.get("retentionInDays", 3653) > 7:
            client.put_retention_policy(
                logGroupName=log_group["logGroupName"], retentionInDays=7
            )
    getLogger().info("Succesfully set retention to log groups for 7 days")


def log_groups() -> Generator[LogGroupTypeDef, None, None]:
    response = client.describe_log_groups()
    for log_group in response.get("logGroups", []):
        yield log_group
    while nextToken := response.get("nextToken"):
        response = client.describe_log_groups(nextToken=nextToken)
        for log_group in response.get("logGroups", []):
            yield log_group
