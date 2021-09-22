{
  "Comment": "Reads Echo Items on the SQS queue and rebuilds the respective AWS resources",
  "StartAt": "CheckSQS",
  "States": {
    "CheckSQS": {
      "Comment": "Check for any New messages on the queue and process it, if not go to sleep",
      "Type": "Task",
      "Resource": "${function_arn}",
      "Parameters": {
        "TaskName": "CheckSQS",
        "QueueUrl": "${queue_url}"
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
      "Parameters":{  
        "StateMachineArn":"${my_arn}"
       },
       "End": true
    }
  }
}