{
	"Comment": "Reads Echo Items on the SQS queue and rebuilds the respective AWS resources",
	"StartAt": "CheckForMessages",
	"States": {
		"CheckForMessages": {
			"Comment": "Check for any New messages on the queue and process it, if not go to sleep",
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
			"Next": "ProcessOrSleep"
		},
		"ProcessOrSleep": {
			"Comment": "Conditional step to process message or go to sleep",
			"Type": "Choice",
			"Choices": [
				{
					"Variable": "$.new_messages",
					"BooleanEquals": true,
					"Next": "Process"
				},
				{
					"Variable": "$.new_messages",
					"BooleanEquals": false,
					"Next": "Sleep"
				}
			]
		},
		"Process": {
			"Comment": "Process if any new messages",
			"Type": "Task",
      "Parameters": {
				"task_name": "Process",
        "Payload.$": "$.payload"
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