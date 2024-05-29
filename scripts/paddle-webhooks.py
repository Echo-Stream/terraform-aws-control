import hashlib
import json
from datetime import datetime
from hmac import HMAC
from http import HTTPStatus
from logging import getLogger
from time import time
from typing import Any, Dict

import boto3
from echo_tools.globals import Globals
from echo_tools.tenant import Tenant
from fastapi.applications import FastAPI
from fastapi.exceptions import HTTPException
from fastapi.params import Depends
from mangum import Mangum
from mangum.types import LambdaContext, LambdaEvent
from pydantic.main import BaseModel
from starlette.requests import Request

PADDLE_WEBHOOKS_SECRET: str = None
PADDLE_WEBHOOKS_WHITELIST = (
    "34.232.58.13 34.195.105.136 34.237.3.244 35.155.119.135 52.11.166.252 34.212.5.7"
    if Globals().environment == "prod"
    else "34.194.127.46 54.234.237.108 3.208.120.145 44.226.236.210 44.241.183.62 100.20.172.113"
)


class PaddleEvent(BaseModel):
    data: Dict[str, Any]
    event_id: str
    event_type: str
    notification_id: str
    occurred_at: datetime


def paddle_webhooks_secret() -> str:
    global PADDLE_WEBHOOKS_SECRET
    if PADDLE_WEBHOOKS_SECRET is None:
        PADDLE_WEBHOOKS_SECRET = boto3.client("secretsmanager").get_secret_value(
            SecretId="${paddle_webhooks_secret_arn}"
        )["SecretString"]
    return PADDLE_WEBHOOKS_SECRET


async def verify_webhook(request: Request):
    if request.client.host not in PADDLE_WEBHOOKS_WHITELIST:
        raise HTTPException(HTTPStatus.FORBIDDEN, "Host not whitelisted")
    ts: str = None
    h1: list[str] = []
    for k, _, v in [
        element.partition("=")
        for element in request.headers.get("Paddle-Signature", "").split(";")
    ]:
        if k == "ts":
            ts = v
        elif k == "h1":
            h1.append(v)
    if not ts or time() - int(ts) > 5:
        raise HTTPException(HTTPStatus.UNAUTHORIZED, "Timestamp not recent")
    h1_computed = HMAC(
        paddle_webhooks_secret().encode(),
        ts.encode() + b":" + await request.body(),
        hashlib.sha256,
    ).hexdigest()
    if h1_computed not in h1:
        raise HTTPException(HTTPStatus.UNAUTHORIZED, "Signature mismatch")


APP = FastAPI(dependencies=[Depends(verify_webhook)])


@APP.post("/", status_code=HTTPStatus.OK)
async def webhook(event: PaddleEvent):
    entity, _, event_type = event.event_type.partition(".")
    if entity == "subscription":
        subscription_id = event.data["id"]
        try:
            if event_type == "created" and (
                tenant := Tenant.get_object(
                    name=event.data.get("custom_data", {}).get("tenant")
                )
            ):
                tenant.subscriptionId = subscription_id
                tenant.update_object()
            elif event_type == "cancelled" and (
                tenant := Tenant.get_by_subscription_id(subscriptionId=subscription_id)
            ):
                tenant.remove_object()
        except Exception:
            getLogger().exception("Failed to process event")


def lambda_handler(event: LambdaEvent, context: LambdaContext) -> None:
    getLogger().info(f"Processing event:\n{json.dumps(event, indent=2)}")
    return Mangum(APP)(event, context)
