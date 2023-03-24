variable "slack_bot_token" {
  type = string

  description = "Bot User OAuth Token. Can be found in Settings > Install App."
}

variable "workspace_name" {
  type = string

  description = "Slack workspace for widget"
}
