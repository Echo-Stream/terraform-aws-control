from logging import INFO, getLogger
from time import sleep
from typing import TYPE_CHECKING, Generator

import boto3

if TYPE_CHECKING:
    from mypy_boto3_ssm.type_defs import ActivationTypeDef
else:
    ActivationTypeDef = dict

getLogger().setLevel(INFO)

client = boto3.client("ssm")


def lambda_handler(event, context):
    expired_count = 0
    for activation in activations():
        if activation["Expired"]:
            client.delete_activation(ActivationId=activation["ActivationId"])
            sleep(0.05)
            expired_count += 1
    getLogger().info(f"Successfully deleted {expired_count} expired activation")


def activations() -> Generator[ActivationTypeDef, None, None]:
    response = client.describe_activations()
    for activation in response.get("ActivationList", []):
        yield activation
    while nextToken := response.get("NextToken"):
        response = client.describe_activations(NextToken=nextToken)
        for activation in response.get("ActivationList", []):
            yield activation
