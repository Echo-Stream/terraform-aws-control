"""
Send an environment specific config
for reactjs webapp on /config/config.json
"""

import json

BODY = json.dumps(
    {
        "billingEnabled": ${billing_enabled},
        "clientId": "${client_id}",
        "graphqlEndpoint": "${graphql_endpoint}",
        "region": "${region}",
        "userPoolId": "${user_pool_id}",
    },
    separators=(",", ":"),
)


def lambda_handler(event, context):
    return {
        "status": "200",
        "statusDescription": "OK",
        "headers": {
            "cache-control": [{"key": "Cache-Control", "value": "max-age=100"}],
            "content-type": [{"key": "Content-Type", "value": "application/json"}],
        },
        "body": BODY,
    }
