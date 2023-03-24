# fwd-tweet-widget
Widget that displays some message

## Architecture
0. Widget is built with webpack moudle federation and deployed to S3
0. Widget gets the last tweet via a Lambda function
    which is just reading `last_message` table
0. `last_message` DynamoDB table contains only the last message from Slack and
    it gets updated on insert to `slack_messages` table
0. `slack_messages` table stores all messages from Slack
0. `slack_messages` table gets updated by `slackBot` Lambda function
0. `slackBot` triggered via webhook requested by Slack

```
                           AWS Lambda                   AWS DynamoDB
|-------|                 |----------|               |----------------|
| Slack | -- webhooks --> | slackBot | -- writes --> | slack_messages |
|-------|                 |----------|               |----------------|
                                                             |
                                                     an uptade triggers
                                                             |
                                                             V
                      AWS DynamoDB                      AWS Lambda
                    |--------------|               |-------------------|
                    | last_message | <-- writes -- | updateLastMessage |
                    |--------------|               |-------------------|
                           ^
                            \
                            reads
                                \
 static js                   AWS Lambda
|--------|                 |--------------|
| widget | -- requests --> | listMessages |
|--------|                 |--------------|
```

## Welcome to your CDK TypeScript project

This is a blank project for CDK development with TypeScript.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Useful commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `cdk deploy`      deploy this stack to your default AWS account/region
* `cdk diff`        compare deployed stack with current state
* `cdk synth`       emits the synthesized CloudFormation template
