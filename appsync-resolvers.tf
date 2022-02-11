resource "aws_appsync_resolver" "invoke_resolvers" {
  depends_on = [
    module.appsync_datasource_
  ]
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = each.value["field"]
  for_each          = local.invoke_resolvers
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = each.value["type"]
}

resource "aws_appsync_resolver" "batch_invoke_resolvers" {
  depends_on = [
    module.appsync_datasource_
  ]
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = each.value["field"]
  for_each          = local.batch_invoke_resolvers
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = each.value["type"]
}

locals {
  invoke_resolvers = {
    api_user_delete = {
      field = "Delete"
      type  = "ApiUser"
    }
    api_user_list_changes = {
      field = "ListChanges"
      type  = "ApiUser"
    }
    api_user_reset_password = {
      field = "ResetPassword"
      type  = "ApiUser"
    }
    api_user_update = {
      field = "Update"
      type  = "ApiUser"
    }
    app_change_receiver_node_create_audit_records = {
      field = "CreateAuditRecords"
      type  = "AppChangeReceiverNode"
    }
    bitmap_router_node_delete = {
      field = "Delete"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_list_changes = {
      field = "ListChanges"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_list_log_events = {
      field = "ListLogEvents"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_update = {
      field = "Update"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_validate = {
      field = "Validate"
      type  = "BitmapRouterNode"
    }
    bitmapper_function_delete = {
      field = "Delete"
      type  = "BitmapperFunction"
    }
    bitmapper_function_list_changes = {
      field = "ListChanges"
      type  = "BitmapperFunction"
    }
    bitmapper_function_update = {
      field = "Update"
      type  = "BitmapperFunction"
    }
    bitmapper_function_validate = {
      field = "Validate"
      type  = "BitmapperFunction"
    }
    create_api_user = {
      field = "CreateApiUser"
      type  = "Mutation"
    }
    create_bitmap_router_node = {
      field = "CreateBitmapRouterNode"
      type  = "Mutation"
    }
    create_bitmapper_function = {
      field = "CreateBitmapperFunction"
      type  = "Mutation"
    }
    create_cross_account_app = {
      field = "CreateCrossAccountApp"
      type  = "Mutation"
    }
    create_cross_tenant_receiving_app = {
      field = "CreateCrossTenantReceivingApp"
      type  = "Mutation"
    }
    create_cross_tenant_sending_app = {
      field = "CreateCrossTenantSendingApp"
      type  = "Mutation"
    }
    create_cross_tenant_sending_node = {
      field = "CreateCrossTenantSendingNode"
      type  = "Mutation"
    }
    create_edge = {
      field = "CreateEdge"
      type  = "Mutation"
    }
    create_external_app = {
      field = "CreateExternalApp"
      type  = "Mutation"
    }
    create_external_node = {
      field = "CreateExternalNode"
      type  = "Mutation"
    }
    create_kms_key = {
      field = "CreateKmsKey"
      type  = "Mutation"
    }
    create_managed_app = {
      field = "CreateManagedApp"
      type  = "Mutation"
    }
    create_managed_node = {
      field = "CreateManagedNode"
      type  = "Mutation"
    }
    create_managed_node_type = {
      field = "CreateManagedNodeType"
      type  = "Mutation"
    }
    create_message_type = {
      field = "CreateMessageType"
      type  = "Mutation"
    }
    create_processor_function = {
      field = "CreateProcessorFunction"
      type  = "Mutation"
    }
    create_processor_node = {
      field = "CreateProcessorNode"
      type  = "Mutation"
    }
    create_tenant = {
      field = "CreateTenant"
      type  = "Mutation"
    }
    create_timer_node = {
      field = "CreateTimerNode"
      type  = "Mutation"
    }
    cross_account_app_delete = {
      field = "Delete"
      type  = "CrossAccountApp"
    }
    cross_account_app_get_aws_credentials = {
      field = "GetAwsCredentials"
      type  = "CrossAccountApp"
    }
    cross_account_app_list_changes = {
      field = "ListChanges"
      type  = "CrossAccountApp"
    }
    cross_account_app_reset_password = {
      field = "ResetPassword"
      type  = "CrossAccountApp"
    }
    cross_tenant_receiving_app_delete = {
      field = "Delete"
      type  = "CrossTenantReceivingApp"
    }
    cross_tenant_receiving_app_list_changes = {
      field = "ListChanges"
      type  = "CrossTenantReceivingApp"
    }
    cross_tenant_receiving_app_update = {
      field = "Update"
      type  = "CrossTenantReceivingApp"
    }
    cross_tenant_receiving_node_delete = {
      field = "Delete"
      type  = "CrossTenantReceivingNode"
    }
    cross_tenant_receiving_node_list_changes = {
      field = "ListChanges"
      type  = "CrossTenantReceivingNode"
    }
    cross_tenant_receiving_node_update = {
      field = "Update"
      type  = "CrossTenantReceivingNode"
    }
    cross_tenant_sending_app_delete = {
      field = "Delete"
      type  = "CrossTenantSendingApp"
    }
    cross_tenant_sending_app_list_changes = {
      field = "ListChanges"
      type  = "CrossTenantSendingApp"
    }
    cross_tenant_sending_app_update = {
      field = "Update"
      type  = "CrossTenantSendingApp"
    }
    cross_tenant_sending_node_delete = {
      field = "Delete"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_list_changes = {
      field = "ListChanges"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_list_log_events = {
      field = "ListLogEvents"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_update = {
      field = "Update"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_validate = {
      field = "Validate"
      type  = "CrossTenantSendingNode"
    }
    edge_delete = {
      field = "Delete"
      type  = "Edge"
    }
    edge_list_changes = {
      field = "ListChanges"
      type  = "Edge"
    }
    edge_move = {
      field = "Move"
      type  = "Edge"
    }
    edge_purge = {
      field = "Purge"
      type  = "Edge"
    }
    edge_update = {
      field = "Update"
      type  = "Edge"
    }
    external_app_delete = {
      field = "Delete"
      type  = "ExternalApp"
    }
    external_app_get_aws_credentials = {
      field = "GetAwsCredentials"
      type  = "ExternalApp"
    }
    external_app_list_changes = {
      field = "ListChanges"
      type  = "ExternalApp"
    }
    external_app_reset_password = {
      field = "ResetPassword"
      type  = "ExternalApp"
    }
    external_app_update = {
      field = "Update"
      type  = "ExternalApp"
    }
    external_node_create_audit_records = {
      field = "CreateAuditRecords"
      type  = "ExternalNode"
    }
    external_node_delete = {
      field = "Delete"
      type  = "ExternalNode"
    }
    external_node_list_changes = {
      field = "ListChanges"
      type  = "ExternalNode"
    }
    external_node_update = {
      field = "Update"
      type  = "ExternalNode"
    }
    get_api_user = {
      field = "GetApiUser"
      type  = "Query"
    }
    get_app = {
      field = "GetApp"
      type  = "Query"
    }
    get_bulk_data_storage = {
      field = "GetBulkDataStorage"
      type  = "Query"
    }
    get_edge = {
      field = "GetEdge"
      type  = "Query"
    }
    get_function = {
      field = "GetFunction"
      type  = "Query"
    }
    get_kms_key = {
      field = "GetKmsKey"
      type  = "Query"
    }
    get_managed_node_type = {
      field = "GetManagedNodeType"
      type  = "Query"
    }
    get_message_type = {
      field = "GetMessageType"
      type  = "Query"
    }
    get_node = {
      field = "GetNode"
      type  = "Query"
    }
    get_supported_regions = {
      field = "GetSupportedRegions"
      type  = "Query"
    }
    get_tenant = {
      field = "GetTenant"
      type  = "Query"
    }
    get_tenant_user = {
      field = "GetTenantUser"
      type  = "Query"
    }
    get_user = {
      field = "GetUser"
      type  = "Query"
    }
    kms_key_delete = {
      field = "Delete"
      type  = "KmsKey"
    }
    kms_key_list_changes = {
      field = "ListChanges"
      type  = "KmsKey"
    }
    kms_key_update = {
      field = "Update"
      type  = "KmsKey"
    }
    list_api_users = {
      field = "ListApiUsers"
      type  = "Query"
    }
    list_apps = {
      field = "ListApps"
      type  = "Query"
    }
    list_changes = {
      field = "ListChanges"
      type  = "Query"
    }
    list_functions = {
      field = "ListFunctions"
      type  = "Query"
    }
    list_kms_keys = {
      field = "ListKmsKeys"
      type  = "Query"
    }
    list_managed_node_types = {
      field = "ListManagedNodeTypes"
      type  = "Query"
    }
    list_message_types = {
      field = "ListMessageTypes"
      type  = "Query"
    }
    list_nodes = {
      field = "ListNodes"
      type  = "Query"
    }
    list_tenant_users = {
      field = "ListTenantUsers"
      type  = "Query"
    }
    list_tenants = {
      field = "ListTenants"
      type  = "Query"
    }
    managed_app_delete = {
      field = "Delete"
      type  = "ManagedApp"
    }
    managed_app_deregister_managed_instance = {
      field = "DeregisterManagedInstance"
      type  = "ManagedApp"
    }
    managed_app_get_aws_credentials = {
      field = "GetAwsCredentials"
      type  = "ManagedApp"
    }
    managed_app_list_changes = {
      field = "ListChanges"
      type  = "ManagedApp"
    }
    managed_app_reset_password = {
      field = "ResetPassword"
      type  = "ManagedApp"
    }
    managed_app_update = {
      field = "Update"
      type  = "ManagedApp"
    }
    managed_node_create_audit_records = {
      field = "CreateAuditRecords"
      type  = "ManagedNode"
    }
    managed_node_delete = {
      field = "Delete"
      type  = "ManagedNode"
    }
    managed_node_list_changes = {
      field = "ListChanges"
      type  = "ManagedNode"
    }
    managed_node_list_log_events = {
      field = "ListLogEvents"
      type  = "ManagedNode"
    }
    managed_node_type_delete = {
      field = "Delete"
      type  = "ManagedNodeType"
    }
    managed_node_type_list_changes = {
      field = "ListChanges"
      type  = "ManagedNodeType"
    }
    managed_node_type_update = {
      field = "Update"
      type  = "ManagedNodeType"
    }
    managed_node_update = {
      field = "Update"
      type  = "ManagedNode"
    }
    message_type_delete = {
      field = "Delete"
      type  = "MessageType"
    }
    message_type_list_changes = {
      field = "ListChanges"
      type  = "MessageType"
    }
    message_type_update = {
      field = "Update"
      type  = "MessageType"
    }
    message_type_validate = {
      field = "Validate"
      type  = "MessageType"
    }
    processor_function_delete = {
      field = "Delete"
      type  = "ProcessorFunction"
    }
    processor_function_list_changes = {
      field = "ListChanges"
      type  = "ProcessorFunction"
    }
    processor_function_update = {
      field = "Update"
      type  = "ProcessorFunction"
    }
    processor_function_validate = {
      field = "Validate"
      type  = "ProcessorFunction"
    }
    processor_node_delete = {
      field = "Delete"
      type  = "ProcessorNode"
    }
    processor_node_list_changes = {
      field = "ListChanges"
      type  = "ProcessorNode"
    }
    processor_node_list_log_events = {
      field = "ListLogEvents"
      type  = "ProcessorNode"
    }
    processor_node_update = {
      field = "Update"
      type  = "ProcessorNode"
    }
    processor_node_validate = {
      field = "Validate"
      type  = "ProcessorNode"
    }
    tenant_add_user = {
      field = "AddUser"
      type  = "Tenant"
    }
    tenant_delete = {
      field = "Delete"
      type  = "Tenant"
    }
    tenant_list_changes = {
      field = "ListChanges"
      type  = "Tenant"
    }
    tenant_update = {
      field = "Update"
      type  = "Tenant"
    }
    tenant_user_delete = {
      field = "Delete"
      type  = "TenantUser"
    }
    tenant_user_delete_graph_layout = {
      field = "DeleteGraphLayout"
      type  = "TenantUser"
    }
    tenant_user_list_changes = {
      field = "ListChanges"
      type  = "TenantUser"
    }
    tenant_user_save_graph_layout = {
      field = "SaveGraphLayout"
      type  = "TenantUser"
    }
    tenant_user_update = {
      field = "Update"
      type  = "TenantUser"
    }
    timer_node_delete = {
      field = "Delete"
      type  = "TimerNode"
    }
    timer_node_list_changes = {
      field = "ListChanges"
      type  = "TimerNode"
    }
    timer_node_update = {
      field = "Update"
      type  = "TimerNode"
    }
  }

  #######################################################
  ############### Batch Invoke Resolvers ################
  #######################################################

  batch_invoke_resolvers = {
    alert_emitter_node_sendedges = {
      field = "sendEdges"
      type  = "AlertEmitterNode"
    }
    alert_emitter_node_sendmessagetype = {
      field = "sendMessageType"
      type  = "AlertEmitterNode"
    }
    alert_emitter_node_tenant = {
      field = "tenant"
      type  = "AlertEmitterNode"
    }
    api_user_credentials = {
      field = "credentials"
      type  = "ApiUser"
    }
    api_user_tenant = {
      field = "tenant"
      type  = "ApiUser"
    }
    audit_emitter_node_sendedges = {
      field = "sendEdges"
      type  = "AuditEmitterNode"
    }
    audit_emitter_node_sendmessagetype = {
      field = "sendMessageType"
      type  = "AuditEmitterNode"
    }
    audit_emitter_node_tenant = {
      field = "tenant"
      type  = "AuditEmitterNode"
    }
    bitmap_router_node_route_table = {
      field = "routeTable"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_config = {
      field = "config"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_managed_bitmapper = {
      field = "managedBitmapper"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_receive_edges = {
      field = "receiveEdges"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_receive_message_type = {
      field = "receiveMessageType"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_requirements = {
      field = "requirements"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_send_edges = {
      field = "sendEdges"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_send_message_type = {
      field = "sendMessageType"
      type  = "BitmapRouterNode"
    }
    bitmap_router_node_tenant = {
      field = "tenant"
      type  = "BitmapRouterNode"
    }
    bitmapper_function_argumentMessageType = {
      field = "argumentMessageType"
      type  = "BitmapperFunction"
    }
    bitmapper_function_requirements = {
      field = "requirements"
      type  = "BitmapperFunction"
    }
    bitmapper_function_tenant = {
      field = "tenant"
      type  = "BitmapperFunction"
    }
    change_old = {
      field = "old"
      type  = "Change"
    }
    change_new = {
      field = "new"
      type  = "Change"
    }
    change_emitter_node_sendedges = {
      field = "sendEdges"
      type  = "ChangeEmitterNode"
    }
    change_emitter_node_sendMessageType = {
      field = "sendMessageType"
      type  = "ChangeEmitterNode"
    }
    change_emitter_node_tenant = {
      field = "tenant"
      type  = "ChangeEmitterNode"
    }
    cross_account_app_config = {
      field = "config"
      type  = "CrossAccountApp"
    }
    cross_account_app_credentials = {
      field = "credentials"
      type  = "CrossAccountApp"
    }
    cross_account_app_nodes = {
      field = "nodes"
      type  = "CrossAccountApp"
    }
    cross_account_app_iam_policy = {
      field = "iamPolicy"
      type  = "CrossAccountApp"
    }
    cross_account_app_table_access = {
      field = "tableAccess"
      type  = "CrossAccountApp"
    }
    cross_account_app_tenant = {
      field = "tenant"
      type  = "CrossAccountApp"
    }
    cross_account_app_update = {
      field = "Update"
      type  = "CrossAccountApp"
    }
    cross_tenant_receiving_app_nodes = {
      field = "nodes"
      type  = "CrossTenantReceivingApp"
    }
    cross_tenant_receiving_app_tenant = {
      field = "tenant"
      type  = "CrossTenantReceivingApp"
    }
    cross_tenant_receiving_node_app = {
      field = "app"
      type  = "CrossTenantReceivingNode"
    }
    cross_tenant_receiving_node_send_edges = {
      field = "sendEdges"
      type  = "CrossTenantReceivingNode"
    }
    cross_tenant_receiving_node_send_message_type = {
      field = "sendMessageType"
      type  = "CrossTenantReceivingNode"
    }
    cross_tenant_receiving_node_tenant = {
      field = "tenant"
      type  = "CrossTenantReceivingNode"
    }
    cross_tenant_sending_app_nodes = {
      field = "nodes"
      type  = "CrossTenantSendingApp"
    }
    cross_tenant_sending_app_tenant = {
      field = "tenant"
      type  = "CrossTenantSendingApp"
    }
    cross_tenant_sending_node_app = {
      field = "app"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_config = {
      field = "config"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_managed_processor = {
      field = "managedProcessor"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_receive_edges = {
      field = "receiveEdges"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_receive_message_type = {
      field = "receiveMessageType"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_requirements = {
      field = "requirements"
      type  = "CrossTenantSendingNode"
    }
    cross_tenant_sending_node_tenant = {
      field = "tenant"
      type  = "CrossTenantSendingNode"
    }
    dead_letter_emitter_node_sendedges = {
      field = "sendEdges"
      type  = "DeadLetterEmitterNode"
    }
    dead_letter_emitter_node_send_message_type = {
      field = "sendMessageType"
      type  = "DeadLetterEmitterNode"
    }
    dead_letter_emitter_node_tenant = {
      field = "tenant"
      type  = "DeadLetterEmitterNode"
    }
    edge_draining = {
      field = "draining"
      type  = "Edge"
    }
    edge_kms_key = {
      field = "kmsKey"
      type  = "Edge"
    }
    edge_message_counts = {
      field = "messageCounts"
      type  = "Edge"
    }
    edge_message_type = {
      field = "messageType"
      type  = "Edge"
    }
    edge_source = {
      field = "source"
      type  = "Edge"
    }
    edge_target = {
      field = "target"
      type  = "Edge"
    }
    edge_tenant = {
      field = "tenant"
      type  = "Edge"
    }
    external_app_config = {
      field = "config"
      type  = "ExternalApp"
    }
    external_app_credentials = {
      field = "credentials"
      type  = "ExternalApp"
    }
    external_app_nodes = {
      field = "nodes"
      type  = "ExternalApp"
    }
    external_app_table_access = {
      field = "tableAccess"
      type  = "ExternalApp"
    }
    external_app_tenant = {
      field = "tenant"
      type  = "ExternalApp"
    }
    external_node_app = {
      field = "app"
      type  = "ExternalNode"
    }
    external_node_config = {
      field = "config"
      type  = "ExternalNode"
    }
    external_node_receive_edges = {
      field = "receiveEdges"
      type  = "ExternalNode"
    }
    external_node_receive_message_type = {
      field = "receiveMessageType"
      type  = "ExternalNode"
    }
    external_node_send_edges = {
      field = "sendEdges"
      type  = "ExternalNode"
    }
    external_node_send_message_type = {
      field = "sendMessageType"
      type  = "ExternalNode"
    }
    external_node_tenant = {
      field = "tenant"
      type  = "ExternalNode"
    }
    log_emitter_node_sendedges = {
      field = "sendEdges"
      type  = "LogEmitterNode"
    }
    log_emitter_node_send_message_type = {
      field = "sendMessageType"
      type  = "LogEmitterNode"
    }
    log_emitter_node_tenant = {
      field = "tenant"
      type  = "LogEmitterNode"
    }
    login_user_tenant_users = {
      field = "tenantUsers"
      type  = "LoginUser"
    }
    kms_key_tenant = {
      field = "tenant"
      type  = "KmsKey"
    }
    managed_app_config = {
      field = "config"
      type  = "ManagedApp"
    }
    managed_app_credentials = {
      field = "credentials"
      type  = "ManagedApp"
    }
    managed_app_iso = {
      field = "iso"
      type  = "ManagedApp"
    }
    managed_app_managed_instances = {
      field = "managedInstances"
      type  = "ManagedApp"
    }
    managed_app_nodes = {
      field = "nodes"
      type  = "ManagedApp"
    }
    managed_app_table_access = {
      field = "tableAccess"
      type  = "ManagedApp"
    }
    managed_app_tenant = {
      field = "tenant"
      type  = "ManagedApp"
    }
    managed_app_userdata = {
      field = "userdata"
      type  = "ManagedApp"
    }
    app_change_receiver_node_app = {
      field = "app"
      type  = "AppChangeReceiverNode"
    }
    app_change_receiver_node_receive_edge = {
      field = "receiveEdge"
      type  = "AppChangeReceiverNode"
    }
    app_change_receiver_node_receive_message_type = {
      field = "receiveMessageType"
      type  = "AppChangeReceiverNode"
    }
    app_change_receiver_node_tenant = {
      field = "tenant"
      type  = "AppChangeReceiverNode"
    }
    app_change_router_node_receive_edge = {
      field = "receiveEdge"
      type  = "AppChangeRouterNode"
    }
    app_change_router_node_receive_message_type = {
      field = "receiveMessageType"
      type  = "AppChangeRouterNode"
    }
    app_change_router_node_send_edges = {
      field = "sendEdges"
      type  = "AppChangeRouterNode"
    }
    app_change_router_node_send_message_type = {
      field = "sendMessageType"
      type  = "AppChangeRouterNode"
    }
    app_change_router_node_tenant = {
      field = "tenant"
      type  = "AppChangeRouterNode"
    }
    managed_instance_last_ping_date_time = {
      field = "lastPingDateTime"
      type  = "ManagedInstance"
    }
    managed_instance_ping_status = {
      field = "pingStatus"
      type  = "ManagedInstance"
    }
    managed_node_app = {
      field = "app"
      type  = "ManagedNode"
    }
    managed_node_config = {
      field = "config"
      type  = "ManagedNode"
    }
    managed_node_managed_node_type = {
      field = "managedNodeType"
      type  = "ManagedNode"
    }
    managed_node_receive_edges = {
      field = "receiveEdges"
      type  = "ManagedNode"
    }
    managed_node_receive_message_type = {
      field = "receiveMessageType"
      type  = "ManagedNode"
    }
    managed_node_send_edges = {
      field = "sendEdges"
      type  = "ManagedNode"
    }
    managed_node_send_message_type = {
      field = "sendMessageType"
      type  = "ManagedNode"
    }
    managed_node_tenant = {
      field = "tenant"
      type  = "ManagedNode"
    }
    managed_node_type_receive_message_type = {
      field = "receiveMessageType"
      type  = "ManagedNodeType"
    }
    managed_node_type_send_message_type = {
      field = "sendMessageType"
      type  = "ManagedNodeType"
    }
    managed_node_type_tenant = {
      field = "tenant"
      type  = "ManagedNodeType"
    }
    message_type_requirements = {
      field = "requirements"
      type  = "MessageType"
    }
    message_type_tenant = {
      field = "tenant"
      type  = "MessageType"
    }
    processor_function_argument_message_type = {
      field = "argumentMessageType"
      type  = "ProcessorFunction"
    }
    processor_function_requirements = {
      field = "requirements"
      type  = "ProcessorFunction"
    }
    processor_function_result_message_type = {
      field = "returnMessageType"
      type  = "ProcessorFunction"
    }
    processor_function_tenant = {
      field = "tenant"
      type  = "ProcessorFunction"
    }
    processor_node_config = {
      field = "config"
      type  = "ProcessorNode"
    }
    processor_node_managed_processor = {
      field = "managedProcessor"
      type  = "ProcessorNode"
    }
    processor_node_receive_edges = {
      field = "receiveEdges"
      type  = "ProcessorNode"
    }
    processor_node_receive_message_type = {
      field = "receiveMessageType"
      type  = "ProcessorNode"
    }
    processor_node_requirements = {
      field = "requirements"
      type  = "ProcessorNode"
    }
    processor_node_send_edges = {
      field = "sendEdges"
      type  = "ProcessorNode"
    }
    processor_node_send_message_type = {
      field = "sendMessageType"
      type  = "ProcessorNode"
    }
    processor_node_tenant = {
      field = "tenant"
      type  = "ProcessorNode"
    }
    tenant_config = {
      field = "config"
      type  = "Tenant"
    }
    tenant_users = {
      field = "users"
      type  = "Tenant"
    }
    tenant_user_first_name = {
      field = "firstName"
      type  = "TenantUser"
    }
    tenant_user_graph_layouts = {
      field = "graphLayouts"
      type  = "TenantUser"
    }
    tenant_user_last_name = {
      field = "lastName"
      type  = "TenantUser"
    }
    tenant_user_tenant = {
      field = "tenant"
      type  = "TenantUser"
    }
    timer_node_sendedges = {
      field = "sendEdges"
      type  = "TimerNode"
    }
    timer_node_sendmessagetype = {
      field = "sendMessageType"
      type  = "TimerNode"
    }
    timer_node_tenant = {
      field = "tenant"
      type  = "TimerNode"
    }
  }
}