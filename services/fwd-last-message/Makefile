test:
	curl -X POST $$(terraform output -raw base_url) -H 'Content-Type: application/json' -d '{"message":{"text":"Hello, World!","author":"Makefile"}}'

deploy:
	pushd "../fwd-slack-client"; \
		TABLE_STREAM=$$(terraform output -raw table_stream_arn); \
		popd; \
		aws-vault exec fwd-tweet -- terraform apply -var "input_table_stream_arn=$$TABLE_STREAM" -auto-approve

destroy:
	aws-vault exec fwd-tweet -- terraform destroy

list:
	aws-vault exec fwd-tweet -- aws dynamodb scan --table-name $$(terraform output -raw table_name)
