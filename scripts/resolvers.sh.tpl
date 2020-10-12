#!/usr/bin/env bash

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetMessageType --data-source-name ${message_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetUsersForTenant --data-source-name ${tenant_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetUser --data-source-name ${tenant_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name SearchNodes --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name SearchEdges --data-source-name ${edge_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name SearchApps --data-source-name ${app_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name ListKeys --data-source-name ${kms_key_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name ListMessageTypes --data-source-name ${message_type_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name ValidateFunction --data-source-name ${validate_function_datasource}