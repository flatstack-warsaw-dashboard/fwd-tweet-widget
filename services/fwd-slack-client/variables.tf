variable "default_slack_workspace" {
  type = string
}

variable "slack_bot_token" {
  type = string

  description = "Bot User OAuth Token. Can be found in Settings > Install App."
}
