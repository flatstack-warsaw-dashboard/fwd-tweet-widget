const buildMessage = (message) => ({
  ...message,
  createdAt: new Date(message.createdAt)
});

const fetchMessages = () =>
  fetch(__API_URL__)
    .then(response => response.json())
    .then(({ messages }) => messages.map(buildMessage))
    .catch(error => ({ messages: [{ text: error.name, author: error.type, createdAt: new Date() }] }));

export default fetchMessages;
