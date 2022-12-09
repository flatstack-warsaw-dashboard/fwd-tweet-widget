test:
	curl -X POST $$(terraform output -raw base_url) -H 'Content-Type: application/json' -d '{"event": {"blocks":[]}}'

deploy:
	aws-vault exec fwd-tweet -- terraform apply

destroy:
	aws-vault exec fwd-tweet -- terraform destroy
