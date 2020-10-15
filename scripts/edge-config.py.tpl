import json
'''
Dynamically send an environment specific config
for reactjs webapp on /config/config.json
'''
def lambda_handler(event, context):
	content = {
				'endpoint': '${graphql_endpoint}',
				'authenticationType': 'AMAZON_COGNITO_USER_POOLS',
				'clientId': '${client_id}',
				'region': '${region}',
				'userPoolId': '${user_pool_id}'
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