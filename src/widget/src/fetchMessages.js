const buildMessage = (message) => ({
  ...message,
  createdAt: new Date(message.createdAt)
});

const fetchMessages = (apiUrl) =>
  fetch(apiUrl)
    .then(response => response.json())
    .then(({ messages }) => messages.map(buildMessage))
    .catch(error => [
      { text: error.message, author: error.name, createdAt: new Date() }
    ]);

export default fetchMessages;
