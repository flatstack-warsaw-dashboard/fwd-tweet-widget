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
