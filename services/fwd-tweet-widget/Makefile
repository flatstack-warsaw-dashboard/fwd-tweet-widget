deploy:
	npm run build && aws-vault exec fwd-tweet -- terraform apply

destroy:
	aws-vault exec fwd-tweet -- terraform destroy
