const AWS = require('aws-sdk');

const region = process.env.REGION;
const table = process.env.DB_TABLE;
const db = new AWS.DynamoDB({ region });

const appendMessage = async ({ text, sender }) => {
  return await db.putItem({
    TableName: table,
    Item: {
      uuid: { S: AWS.util.uuid.v4() },
      created_at: { S: new Date().toISOString() },
      text: { S: text },
      sender: { S: sender },
    },
  }).promise();
};

module.exports.handler = async (_event) => {
  await appendMessage({ text: "Hello there!", sender: "Dima" });
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ message: 'OK' }),
  };
};
