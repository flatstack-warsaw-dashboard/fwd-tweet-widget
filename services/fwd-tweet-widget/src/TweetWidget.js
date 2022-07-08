class TweetWidget extends HTMLElement {
  constructor() {
    super();

    const shadow = this.attachShadow({ mode: 'open' });
    this.wrapper = document.createElement('div');
    shadow.appendChild(this.wrapper);

    this.fetchMessages();
  }

  fetchMessages() {
    fetch("https://egtmm6l7gl.execute-api.eu-central-1.amazonaws.com/production")
      .then(response => {
        console.log({ ok: response.ok });
      });
  }
}

export default TweetWidget;
