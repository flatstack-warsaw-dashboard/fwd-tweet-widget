test:
	curl -X POST $$(terraform output -raw base_url) -H 'Content-Type: application/json' -d '{"message":{"text":"Hello, World!","author":"Makefile"}}'

deploy:
	aws-vault exec fwd-tweet -- terraform apply

destroy:
	aws-vault exec fwd-tweet -- terraform destroy

list:
	aws-vault exec fwd-tweet -- aws dynamodb scan --table-name $$(terraform output -raw table_name)
