import formatDate from './formatDate.js';
import dayOfWeek from "./dayOfWeek.js";

const escapeHtml = (text) => new Option(text).innerHTML;

const cssStyles = `
<style>
  h2.inline {
    font-size: inherit;
    display: inline;
  }

  article {
    font-family: monospace;
    padding: 5px;
  }

  article:not(:last-child) {
    border-bottom: 1px solid black;
  }

  .main {
    padding-left: 2ch;
  }

  .secondary {
    color: rgba(1, 1, 1, 0.5);
  }
</style>
`;

const renderMessages = (rootElement) => (messages) => {
  const renderedMessages = messages
    .sort((a, b) => b.createdAt - a.createdAt)
    .slice(0, 3)
    .map(message => `
      <article>
        <header>
          <span>${message.author}<span>
          <span class="secondary">in</span>
          <h2 class="inline">#${message.channel}</h2><span>:</span>
        </header>
        <section class="main">${escapeHtml(message.text)}</section>
        <footer>
          <span class="secondary">${dayOfWeek(message.createdAt)}</span>
          <time datetime="${message.createdAt.toISOString()}">
            ${formatDate(message.createdAt)}
          </time>
        </footer>
      </article>
    `);

  rootElement.innerHTML = [cssStyles, ...renderedMessages].join('\n');
};

export default renderMessages;
