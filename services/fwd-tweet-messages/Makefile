test:
	curl $$(terraform output base_url | tr -d '"')

deploy:
	aws-vault exec fwd-tweet -- terraform apply

destroy:
	aws-vault exec fwd-tweet -- terraform destroy

list:
	aws-vault exec fwd-tweet -- aws dynamodb scan --table-name $$(terraform output table_name | tr -d '"')

apply:
	aws-vault exec fwd-tweet -- terraform apply
