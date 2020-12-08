'''
Dynamically send an environment specific config
for reactjs webapp on /config/config.json
'''

import json

def lambda_handler(event, context):
	content = {
				'debug': true,
				'clientId': '${client_id}',
				'graphQL':{
					'graphqlEndpoint': '${graphql_endpoint}',
					'appsync_authenticationType': 'AMAZON_COGNITO_USER_POOLS',
					'aws_user_pools_web_client_id': '${api_id}'
				},
				'LogoutTimeout': 900000,
				'queryLimit': 300,
				'region': '${region}',
				'UserPoolId': '${user_pool_id}'
	}
	response = {
		'status': '200',
		'statusDescription': 'OK',
		'headers': {
			'cache-control': [
				{
					'key': 'Cache-Control',
					'value': 'max-age=100'
				}
			],
			"content-type": [
				{
					'key': 'Content-Type',
					'value': 'application/json'
				}
			]
		},
		'body': json.dumps(content)
	}
	return response