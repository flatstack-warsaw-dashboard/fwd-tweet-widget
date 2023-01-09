const buildMessage = (message) => ({
  ...message,
  createdAt: new Date(message.createdAt)
});

const renderMessages = (rootElement) => (messages) => {
  rootElement.innerHTML = messages.map(message => `
    <article>
      <section>
        <header>
          <span>${message.author}<span>
          <span class="secondary"> said:</span>
        </header>
        <main>${message.text}</main>
        <footer>
          <span class="secondary">${dayOfWeek(message.createdAt)} </span>
          <time>${formatDate(message.createdAt)}</time>
        </footer>
      <section>
    </article>
  `).join('\n');
};

const dayOfWeek = (date) => date.toLocaleString('default', { weekday: 'short' });

const formatDate = (date) => date.toLocaleDateString('default', { month: 'short', day: '2-digit', year: 'numeric' });


class TweetWidget extends HTMLElement {
  constructor() {
    super();

    const shadow = this.attachShadow({ mode: 'open' });
    this.wrapper = document.createElement('div');
    shadow.appendChild(this.wrapper);
    shadow.appendChild(this.styles());

    this.fetchMessages().then(renderMessages(this.wrapper));
  }

  fetchMessages() {
    return fetch(__API_URL__)
      .then(response => response.json())
      .then(({ messages }) => messages.map(buildMessage))
      .catch(error => ({ messages: [{ text: error.name, author: error.type, createdAt: new Date() }] }));
  }

  styles() {
    let styleTag = document.createElement('style');
    styleTag.innerHTML = `
      section {
        font-family: monospace;
      }

      main {
        text-indent: 2ch;
      }

      .secondary {
        color: rgba(1, 1, 1, 0.5);
      }
    `;
    return styleTag;
  }
}

export default TweetWidget;
