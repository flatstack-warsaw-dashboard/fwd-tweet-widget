deploy:
	cd services/fwd-slack-client && make deploy
	cd services/fwd-last-message && make deploy
	cd services/fwd-tweet-widget && make deploy
