"""
Starts the rebuild-notifications IFF it is not running
alread.
"""

import boto3
from logging import getLogger, INFO
from uuid import uuid4

getLogger().setLevel(INFO)


def lambda_handler(event, context):
    sfn_client = boto3.client("stepfunctions")
    getLogger().info("Ensuring there are no active executions")
    if sfn_client.list_executions(
        maxResults=1,
        stateMachineArn="${state_machine_arn}",
        statusFilter="RUNNING",
    ).get("executions"):
        getLogger().warn("Found RUNNING execution, exiting")
        return

    getLogger().info("Starting a new execution")
    sfn_client.start_execution(
        input="{}",
        name=f"EXT-{uuid4()}",
        stateMachineArn="${state_machine_arn}",
    )
    getLogger().info("Started new execution")
