# fwd-tweet-widget
Widget that displays some message

## Architecture
0. Widget is built with webpack moudle federation and deployed to S3
0. Widget gets the last tweet via lambda connected to a websocket
0. The-last-tweet-lambda accesses DynamoDB to find the last tweet
0. DynamoDB is populated via another lambda with HTTP endpoint

The whole pipeline is set up manually.
