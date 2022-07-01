const AWS = require('aws-sdk');

const region = process.env.REGION;
const table = process.env.DB_TABLE;
const db = new AWS.DynamoDB({ region });

const buildMessage = ({ Item }) => ({
  text: Item.text.S,
  createdAt: Item.text.S,
  author: Item.author.S
});

const fetchLastMessage = async () => await db.getItem({
  TableName: "messages",
  Key: {
    id: { N: "1" }
  }
}).promise().then(buildMessage);

module.exports.handler = async (event) => {
  try {
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        messages: [await fetchLastMessage()]
      }),
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
