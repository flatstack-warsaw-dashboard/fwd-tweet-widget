const AWS = require('aws-sdk');

const region = process.env.REGION;
const table = process.env.DB_TABLE;
const db = new AWS.DynamoDB({ region });

const appendMessage = async (data) => {
  return await db.putItem({
    TableName: table,
    Item: {
      id: { N: "1" },
      ...data,
    },
  }).promise();
};

module.exports.handler = async (event) => {
  try {
    let inserts = event.Records.map(({ dynamodb }) => appendMessage(dynamodb.NewImage));

    await Promise.allSettled(inserts);

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
