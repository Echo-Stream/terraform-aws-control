{
	"Comment": "Reads Echo Items on the SQS queue and rebuilds the respective AWS resources",
	"StartAt": "CheckForMessages",
	"States": {
		"CheckForMessages": {
			"Comment": "Check for any New message on the queue and process it, if not go to sleep",
			"Type": "Task",
			"Resource": "${function_arn}",
			"Parameters": {
				"task_name": "CheckForMessages"
			},
			"Retry": [
				{
					"ErrorEquals": [
						"Lambda.ServiceException",
						"Lambda.AWSLambdaException",
						"Lambda.SdkClientException"
					],
					"IntervalSeconds": 2,
					"MaxAttempts": 6,
					"BackoffRate": 2
				}
			],
			"Next": "NotifyOrSleep"
		},
		"NotifyOrSleep": {
			"Comment": "Conditional step to process the message or go to sleep",
			"Type": "Choice",
			"Choices": [
				{
					"Or": [
						{
							"Variable": "$.new_messages",
							"BooleanEquals": true
						},
						{
							"Variable": "$.pagination_token",
							"IsPresent": true
						}
					],
					"Next": "Notify"
				},
				{
					"Variable": "$.new_messages",
					"BooleanEquals": true,
					"Next": "Notify"
				},
				{
					"Variable": "$.new_messages",
					"BooleanEquals": false,
					"Next": "Sleep"
				}
			]
		},
		"Notify": {
			"Comment": "Notify if any new messages",
			"Type": "Task",
			"Parameters": {
				"task_name": "notify",
				"payload.$": "$.payload",
				"pagination_token.$": "$.pagination_token"
			},
			"Resource": "${function_arn}",
			"Next": "Sleep"
		},
		"Sleep": {
			"Comment": "Sleep for ${sleep_time_in_seconds} seconds",
			"Type": "Wait",
			"Seconds": ${sleep_time_in_seconds},
			"Next": "ReinvokeMyself"
		},
		"ReinvokeMyself": {
			"Type": "Task",
			"Resource": "arn:aws:states:::states:startExecution",
			"Parameters": {
				"StateMachineArn": "${my_arn}"
			},
			"End": true
		}
	}
}