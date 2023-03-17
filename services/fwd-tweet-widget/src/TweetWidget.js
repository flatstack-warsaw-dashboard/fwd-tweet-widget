import GenericTweetWidget from "./GenericTweetWidget.js";

class TweetWidget extends GenericTweetWidget {
  constructor() {
    this.setAttribute('href', __API_URL__);
    super();
  }
}

export default TweetWidget;
