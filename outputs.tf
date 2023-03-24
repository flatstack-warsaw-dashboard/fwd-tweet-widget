output "webhook_url" {
  description = "URL for slack client"

  value = module.slack_client.base_url
}

output "api_url" {
  description = "API URL for retreiving messages"

  value = module.list_messages.base_url
}

output "widget_js_url" {
  description = "URL for accessing widget JS component"

  value = module.tweet_widget.dist_file_url
}
