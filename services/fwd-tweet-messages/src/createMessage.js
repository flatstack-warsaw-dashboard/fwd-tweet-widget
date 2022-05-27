const AWS = require('aws-sdk');

const region = process.env.REGION;
const table = process.env.DB_TABLE;
const db = new AWS.DynamoDB({ region });

const appendMessage = async ({ text, author }) => {
  return await db.putItem({
    TableName: table,
    Item: {
      guid: { S: AWS.util.uuid.v4() },
      created_at: { S: new Date().toISOString() },
      text: { S: text },
      author: { S: author },
    },
  }).promise();
};

const messageParams = ({ body }) => {
  const params = JSON.parse(body);
  if (!params || typeof params !== 'object' || !params.message) {
    throw new Error('Invalid message params. Body should be a JSON with message key.');
  }
  const message = params.message;
  if (!message.text || !message.author) {
    throw new Error('Invalid message params. Message text and author are required.');
  }
  return { text: message.text, author: message.author };
};

module.exports.handler = async (event) => {
  try {
    await appendMessage(messageParams(event));

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message: 'OK' }),
    };
  } catch (e) {
    return {
      statusCode: 422,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ error: { message: e.message, event } }),
    };
  }
};
