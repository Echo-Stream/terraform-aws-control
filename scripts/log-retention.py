from logging import INFO, getLogger
from typing import Generator, Union

import boto3

client = boto3.client("logs")
getLogger().setLevel(INFO)


def lambda_handler(event, context):
    for log_group in log_groups():
        if log_group.get("retentionInDays", 3653) > 7:
            client.put_retention_policy(
                logGroupName=log_group["logGroupName"], retentionInDays=7
            )
    getLogger().info("Succesfully set retention to log groups for 7 days")


def log_groups() -> Generator[dict[str, Union[str, int]], None, None]:
    response = client.describe_log_groups()
    for log_group in response.get("logGroups", []):
        yield log_group
    while nextToken := response.get("nextToken"):
        response = client.describe_log_groups(nextToken=nextToken)
        for log_group in response.get("logGroups", []):
            yield log_group
