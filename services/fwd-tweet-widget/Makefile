build: 
	pushd "../fwd-list-messages"; \
		LAMBDA_API_URL=$$(terraform output -raw base_url); \
		popd; \
		env LAMBDA_API_URL=$$LAMBDA_API_URL npm run build 

deploy:
	make build
	aws-vault exec fwd-tweet -- terraform apply

destroy:
	aws-vault exec fwd-tweet -- terraform destroy
