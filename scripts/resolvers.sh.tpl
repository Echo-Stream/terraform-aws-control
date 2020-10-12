#!/usr/bin/env bash

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetMessageType --data-source-name ${message_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetUsersForTenant --data-source-name ${tenant_datasource}