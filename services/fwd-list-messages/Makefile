test:
	curl -X POST "$$(terraform output -raw base_url)"

deploy:
	pushd "../fwd-last-message"; \
		TABLE_ARN=$$(terraform output -raw table_arn); \
		popd; \
		aws-vault exec fwd-tweet -- terraform apply -var "messages_table_arn=$$TABLE_ARN" -auto-approve

destroy:
	aws-vault exec fwd-tweet -- terraform destroy
