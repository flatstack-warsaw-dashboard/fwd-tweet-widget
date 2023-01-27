import formatDate from "./formatDate";
import dayOfWeek from "./dayOfWeek";

const escapeHtml = (text) => new Option(text).innerHTML;

const renderMessages = (rootElement) => (messages) => {
  rootElement.innerHTML = messages.map(message => `
    <article>
      <section>
        <header>
          <span>${message.author}<span>
          <span class="secondary"> said:</span>
        </header>
        <main>${escapeHtml(message.text)}</main>
        <footer>
          <span class="secondary">${dayOfWeek(message.createdAt)} </span>
          <time datetime="${message.createdAt.toISOString()}">
            ${formatDate(message.createdAt)}
          </time>
        </footer>
      <section>
    </article>
  `).join('\n');
};

export default renderMessages;
