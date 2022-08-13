test:
	curl -X POST $$(terraform output -raw base_url)

deploy:
	cd "../fwd-create-message"; \
		TABLE_ARN=$$(terraform output -raw table_arn); \
		cd -; \
		aws-vault exec fwd-tweet -- terraform apply -var "messages_table_arn=$$TABLE_ARN"

destroy:
	aws-vault exec fwd-tweet -- terraform destroy
