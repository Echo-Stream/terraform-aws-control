#!/usr/bin/env bash
#
aws appsync create-resolver --api-id ${api_id} --type-name CognitoUser --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name CognitoUser --field-name tenant --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name DicomTcpInboundNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name DicomTcpInboundNode --field-name tenant --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name DicomTcpInboundNode --field-name sendEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name DicomTcpInboundNode --field-name sendEdges --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name DicomTcpInboundNode --field-name sendMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name DicomTcpInboundNode --field-name sendMessageType --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name DicomTcpInboundNode --field-name app --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name DicomTcpInboundNode --field-name app --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name DicomTcpOutboundNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name DicomTcpOutboundNode --field-name tenant --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name DicomTcpOutboundNode --field-name receiveEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name DicomTcpOutboundNode --field-name receiveEdges --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name DicomTcpOutboundNode --field-name receiveMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name DicomTcpOutboundNode --field-name receiveMessageType --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name DicomTcpOutboundNode --field-name app --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name DicomTcpOutboundNode --field-name app --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Edge --field-name kmsKey --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Edge --field-name kmsKey --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Edge --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Edge --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Edge --field-name source --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Edge --field-name source --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Edge --field-name target --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Edge --field-name target --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Edge --field-name messageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Edge --field-name messageType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ExternalApp --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ExternalApp --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ExternalApp --field-name nodes --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ExternalApp --field-name nodes --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ExternalNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ExternalNode --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ExternalNode --field-name app --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ExternalNode --field-name app --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ExternalNode --field-name sendEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ExternalNode --field-name sendEdges --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ExternalNode --field-name sendMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ExternalNode --field-name sendMessageType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ExternalNode --field-name receiveEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ExternalNode --field-name receiveEdges --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ExternalNode --field-name receiveMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ExternalNode --field-name receiveMessageType --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Hl7MllpInboundNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Hl7MllpInboundNode --field-name tenant --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Hl7MllpInboundNode --field-name sendEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Hl7MllpInboundNode --field-name sendEdges --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Hl7MllpInboundNode --field-name sendMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Hl7MllpInboundNode --field-name sendMessageType --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Hl7MllpInboundNode --field-name app --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Hl7MllpInboundNode --field-name app --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Hl7MllpOutboundNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Hl7MllpOutboundNode --field-name tenant --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Hl7MllpOutboundNode --field-name receiveEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Hl7MllpOutboundNode --field-name receiveEdges --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Hl7MllpOutboundNode --field-name receiveMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Hl7MllpOutboundNode --field-name receiveMessageType --data-source-name ${sub_field_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Hl7MllpOutboundNode --field-name app --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Hl7MllpOutboundNode --field-name app --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name KmsKey --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name KmsKey --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ManagedApp --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ManagedApp --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ManagedApp --field-name nodes --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ManagedApp --field-name nodes --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name MessageType --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name MessageType --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name AppNotification --data-source-name ${app_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name AppNotification --data-source-name ${app_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name NodeNotification --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name NodeNotification --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name EdgeNotification --data-source-name ${edge_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name EdgeNotification --data-source-name ${edge_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name MessageTypeNotification --data-source-name ${message_type_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name MessageTypeNotification --data-source-name ${message_type_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutDicomTcpInboundNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutDicomTcpInboundNode --data-source-name ${node_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutDicomTcpOutboundNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutDicomTcpOutboundNode --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutEdge --data-source-name ${edge_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutEdge --data-source-name ${edge_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutExternalApp --data-source-name ${app_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutExternalApp --data-source-name ${app_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutExternalNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutExternalNode --data-source-name ${node_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutHl7MllpInboundNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutHl7MllpInboundNode --data-source-name ${node_datasource}

# aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutHl7MllpOutboundNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutHl7MllpOutboundNode --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutKmsKey --data-source-name ${kms_key_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutKmsKey --data-source-name ${kms_key_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutManagedApp --data-source-name ${app_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutManagedApp --data-source-name ${app_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutMessageType --data-source-name ${message_type_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutMessageType --data-source-name ${message_type_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutRouterNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutRouterNode --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutTenant --data-source-name ${tenant_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutTenant --data-source-name ${tenant_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutTransNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutTransNode --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutXTenantSendingApp --data-source-name ${app_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutXTenantSendingApp --data-source-name ${app_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutXTenantSendingNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutXTenantSendingNode --data-source-name ${node_datasource}           

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name AddUserToTenant --data-source-name ${tenant_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name AddUserToTenant --data-source-name ${tenant_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteEdge --data-source-name ${edge_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteEdge --data-source-name ${edge_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteApp --data-source-name ${app_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteApp --data-source-name ${app_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteMessageType --data-source-name ${message_type_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteMessageType --data-source-name ${message_type_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteNode --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name ResetAppPassword --data-source-name ${app_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name ResetAppPassword --data-source-name ${app_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteTenant --data-source-name ${tenant_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteTenant --data-source-name ${tenant_datasource}aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetMessageType --data-source-name ${message_type_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name GetMessageType --data-source-name ${message_type_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetUsersForTenant --data-source-name ${tenant_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name GetUsersForTenant --data-source-name ${tenant_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetUser --data-source-name ${tenant_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name GetUser --data-source-name ${tenant_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name SearchNodes --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name SearchNodes --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name SearchEdges --data-source-name ${edge_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name SearchEdges --data-source-name ${edge_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name SearchApps --data-source-name ${app_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name SearchApps --data-source-name ${app_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name ListKeys --data-source-name ${kms_key_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name ListKeys --data-source-name ${kms_key_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name ListMessageTypes --data-source-name ${message_type_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name ListMessageTypes --data-source-name ${message_type_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name ValidateFunction --data-source-name ${validate_function_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name ValidateFunction --data-source-name ${validate_function_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetLargeMessageStorage --data-source-name ${large_message_storage_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name GetLargeMessageStorage --data-source-name ${large_message_storage_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name GetTenantUser --data-source-name ${tenant_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name GetTenantUser --data-source-name ${tenant_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name RouterNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name RouterNode --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name RouterNode --field-name sendEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name RouterNode --field-name sendEdges --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name RouterNode --field-name sendMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name RouterNode --field-name sendMessageType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name RouterNode --field-name receiveEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name RouterNode --field-name receiveEdges --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name RouterNode --field-name receiveMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name RouterNode --field-name receiveMessageType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Subscription --field-name appUpdated --data-source-name ${subscription_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Subscription --field-name appUpdated --data-source-name ${subscription_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Subscription --field-name nodeUpdated --data-source-name ${subscription_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Subscription --field-name nodeUpdated --data-source-name ${subscription_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Subscription --field-name edgeUpdated --data-source-name ${subscription_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Subscription --field-name edgeUpdated --data-source-name ${subscription_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Subscription --field-name messageTypeUpdated --data-source-name ${subscription_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Subscription --field-name messageTypeUpdated --data-source-name ${subscription_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name TransNode --field-name sendEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name TransNode --field-name sendEdges --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name TransNode --field-name sendMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name TransNode --field-name sendMessageType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name TransNode --field-name receiveEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name TransNode --field-name receiveEdges --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name TransNode --field-name receiveMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name TransNode --field-name receiveMessageType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name TransNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name TransNode --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name User --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name User --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantReceivingApp --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantReceivingApp --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantReceivingApp --field-name nodes --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantReceivingApp --field-name nodes --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantReceivingNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantReceivingNode --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantReceivingNode --field-name sendEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantReceivingNode --field-name sendEdges --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantReceivingNode --field-name sendMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantReceivingNode --field-name sendMessageType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantReceivingNode --field-name app --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantReceivingNode --field-name app --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantSendingApp --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantSendingApp --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantSendingApp --field-name nodes --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantSendingApp --field-name nodes --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantSendingNode --field-name tenant --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantSendingNode --field-name tenant --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantSendingNode --field-name receiveEdges --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantSendingNode --field-name receiveEdges --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantSendingNode --field-name receiveMessageType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantSendingNode --field-name receiveMessageType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name XTenantSendingNode --field-name app --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name XTenantSendingNode --field-name app --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name ManagedNode --field-name managedNodeType --data-source-name ${sub_field_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name ManagedNode --field-name managedNodeType --data-source-name ${sub_field_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutManagedNodeType --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutManagedNodeType --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name PutManagedNode --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Mutation --field-name PutManagedNode --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Mutation --field-name DeleteManagedNodeType --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name DeleteManagedNodeType --data-source-name ${node_datasource}

aws appsync create-resolver --api-id ${api_id} --type-name Query --field-name ListManagedNodeTypes --data-source-name ${node_datasource} || aws appsync update-resolver --api-id ${api_id} --type-name Query --field-name ListManagedNodeTypes --data-source-name ${node_datasource}