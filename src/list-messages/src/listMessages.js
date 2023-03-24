const AWS = require('aws-sdk');

const region = process.env.REGION;
const WORKSPACE_NAME = process.env.WORKSPACE_NAME;
const table = process.env.DB_TABLE;
const db = new AWS.DynamoDB.DocumentClient();

const buildMessage = (messageData) => ({
  text: messageData.text,
  createdAt: messageData.posted_at,
  author: messageData.author_name ?? messageData.author_id,
  channel: messageData.channel_name ?? messageData.channel_id,
});

const fetchLastMessage = async () => await db.query({
  TableName: 'last_message',
  KeyConditionExpression: 'workspace_name = :hkey',
  ExpressionAttributeValues: { ':hkey': WORKSPACE_NAME }
}).promise()
  .then((response) => {
    console.debug('Response from DynamoDB', response);
    return response;
  })
  .then(({ Items }) => Items.map(buildMessage));

const jsonResponse = ({ headers = {}, body = {}, status = 200 }) => ({
  statusCode: status,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Headers' : 'Content-Type',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'OPTIONS,GET,HEAD',
    ...headers
  },
  body: JSON.stringify(body)
});

module.exports.handler = async (event) => {
  try {
    return jsonResponse({
      body: {
        messages: await fetchLastMessage(),
      },
    });
  } catch (e) {
    return jsonResponse({
      status: 422,
      body: {
        error: {
          message: e.message,
          event,
        },
      },
    });
  }
};
