import renderMessages from './renderMessages.js';
import fetchMessages from './fetchMessages.js';

class TweetWidget extends HTMLElement {
  constructor() {
    super();

    const shadow = this.attachShadow({ mode: 'open' });
    this.wrapper = document.createElement('div');
    shadow.appendChild(this.wrapper);
    shadow.appendChild(this.styles());

    fetchMessages().then(renderMessages(this.wrapper));
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
