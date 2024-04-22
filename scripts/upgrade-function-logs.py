import json
from logging import INFO, WARNING, getLogger
from typing import List

import boto3
from boto3.dynamodb.conditions import Attr, Key

getLogger("boto3").setLevel(WARNING)
getLogger("botocore").setLevel(WARNING)
getLogger().setLevel(INFO)


def lambda_handler(event, context):
    logs = boto3.client("logs")
    table = boto3.resource("dynamodb").Table("${table_name}")

    node_names: List[str] = []

    query_params = dict(
        IndexName="gsi3",
        KeyConditionExpression=Key("gsi3_pk").eq("InternalNode"),
        FilterExpression=Attr("type").is_in(
            ["BitmapRouterNode", "ProcessorNode", "WebhookNode", "WebSubHubNode"]
        ),
    )

    while True:
        response = table.query(**query_params)
        for item in response.get("Items"):
            node_names.append(item["lambdaConfiguration"]["FunctionName"])
        if last_evaluated_key := response.get("LastEvaluatedKey"):
            query_params["ExclusiveStartKey"] = last_evaluated_key
        else:
            break

    getLogger().info(f"Found nodes:\n{json.dumps(node_names, indent=2)}")

    node_name_2_log_group_suffix = dict(
        BitmapRouterNode="bitmapper",
        ProcessorNode="processor",
        WebhookNode="apiauthenticator",
        WebSubHubNode="hub",
    )

    for node_name in node_names:
        log_group_name = f"/aws/lambda/{node_name}"
        function_log_group_name = f"{log_group_name}/{node_name_2_log_group_suffix[node_name.partition('-')[0]]}"
        response = logs.describe_subscription_filters(
            logGroupName=function_log_group_name
        )
        if not (subscription_filters := response.get("subscriptionFilters")):
            getLogger().warning(f"No subscription filters found for {node_name}")
            continue
        if len(subscription_filters) > 1:
            getLogger().warning(
                f"More than 1 subscription filter found for {node_name}"
            )
            continue
        subscription_filter = subscription_filters[0]
        del subscription_filter["creationTime"]
        del subscription_filter["distribution"]
        getLogger().info(
            f"Deleting subscription filter {subscription_filter['logGroupName']}:{subscription_filter['filterName']}"
        )
        logs.delete_subscription_filter(
            filterName=subscription_filter["filterName"],
            logGroupName=subscription_filter["logGroupName"],
        )
        getLogger().info(f"Deleting log group {subscription_filter['logGroupName']}")
        logs.delete_log_group(logGroupName=subscription_filter["logGroupName"])
        subscription_filter["logGroupName"] = log_group_name
        subscription_filter["filterPattern"] = "%\[\[FUNCTION\]\]%"
        getLogger().info(
            f"Creating subscription filter\n{json.dumps(subscription_filter, indent=2)}"
        )
        logs.put_subscription_filter(**subscription_filter)
