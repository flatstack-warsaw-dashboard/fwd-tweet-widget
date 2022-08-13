const AWS = require('aws-sdk');

const region = process.env.REGION;
const table = process.env.DB_TABLE;
const db = new AWS.DynamoDB({ region });

const buildMessage = ({ Item }) => ({
  text: Item.text.S,
  createdAt: Item.created_at.S,
  author: Item.author.S,
});

const fetchLastMessage = async () => await db.getItem({
  TableName: "messages",
  Key: {
    id: { N: "1" }
  }
}).promise().then(buildMessage);

const jsonResponse = ({ headers = {}, body = {}, status = 200 }) => ({
  statusCode: status,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'OPTIONS,GET,HEAD',
    ...headers
  },
  body: JSON.stringify(body)
});

module.exports.handler = async (event) => {
  try {
    return jsonResponse({
      body: { messages: [await fetchLastMessage()] }
    });
  } catch (e) {
    return jsonResponse({
      status: 422,
      body: { error: { message: e.message, event } },
    });
  }
};
