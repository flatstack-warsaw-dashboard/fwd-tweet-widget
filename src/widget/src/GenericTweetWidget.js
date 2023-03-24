import renderMessages from './renderMessages.js';
import fetchMessages from './fetchMessages.js';

class GenericTweetWidget extends HTMLElement {
  constructor(href) {
    super();

    const shadow = this.attachShadow({ mode: 'open' });
    this.wrapper = document.createElement('div');
    shadow.appendChild(this.wrapper);

    fetchMessages(href).then(renderMessages(this.wrapper));
  }
}

export default GenericTweetWidget;
