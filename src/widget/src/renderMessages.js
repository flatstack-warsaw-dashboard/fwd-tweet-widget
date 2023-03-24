import formatDate from './formatDate.js';
import dayOfWeek from "./dayOfWeek.js";

const escapeHtml = (text) => new Option(text).innerHTML;

const cssStyles = `
<style>
  h2 {
    font-size: 16px;
  }

  article {
    font-family: monospace;
  }

  section {
    text-indent: 2ch;
  }

  .main {
    text-indent: 4ch;
  }

  .secondary {
    color: rgba(1, 1, 1, 0.5);
  }
</style>
`;

const renderMessages = (rootElement) => (messages) => {
  const renderedMessages = messages.map(message => `
    <article>
      <h2>#${message.channel}</h2>
      <section>
        <header>
          <span>${message.author}<span>
          <span class="secondary"> said:</span>
        </header>
        <section class="main">${escapeHtml(message.text)}</section>
        <footer>
          <span class="secondary">${dayOfWeek(message.createdAt)}</span>
          <time datetime="${message.createdAt.toISOString()}">
            ${formatDate(message.createdAt)}
          </time>
        </footer>
      <section>
    </article>
  `);

  rootElement.innerHTML = [cssStyles, ...renderedMessages].join('\n');
};

export default renderMessages;
