build:
	export LAMBDA_API_URL=$$(aws-vault exec fwd-tweet -- terraform output --raw api_url) \
		&& cd src/widget \
		&& npm run build

deploy: build
	aws-vault exec fwd-tweet -- terraform apply
