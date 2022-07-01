test:
	curl -X POST https://egtmm6l7gl.execute-api.eu-central-1.amazonaws.com/production

deploy:
	cd "../fwd-create-message"; \
		TABLE_ARN=$$(terraform output -raw table_arn); \
		cd "../fwd-list-messages"; \
		aws-vault exec fwd-tweet -- terraform apply -var "messages_table_arn=$$TABLE_ARN"

destroy:
	aws-vault exec fwd-tweet -- terraform destroy
