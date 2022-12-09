const buildMessage = (message) => ({
  ...message,
  createdAt: new Date(message.createdAt)
});

const renderMessages = (rootElement) => (messages) => {
  rootElement.innerHTML = messages.map(message => `
    <article>
      <section>
        <header>
          ${message.author}
          <span class="secondary"> said:</span>
        </header>
        <main>${message.text}</main>
        <footer>
          <span class="secondary">${dayOfWeek(message.createdAt)} </span>
          ${formatDate(message.createdAt)}
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
    return fetch("https://egtmm6l7gl.execute-api.eu-central-1.amazonaws.com/production")
      .then(response => response.json())
      .catch(_ => ({ messages: [] }))
      .then(({ messages }) => messages.map(buildMessage));
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
