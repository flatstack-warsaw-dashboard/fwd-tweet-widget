import GenericTweetWidget from "./GenericTweetWidget.js";

class TweetWidget extends GenericTweetWidget {
  constructor() {
    super(__API_URL__);
  }
}

export default TweetWidget;
