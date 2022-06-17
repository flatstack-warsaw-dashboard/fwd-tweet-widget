const AWS = require('aws-sdk');

const region = process.env.REGION;
const table = process.env.DB_TABLE;
const db = new AWS.DynamoDB({ region });

module.exports.handler = async (event) => {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ message: 'OK' }),
  };
};
