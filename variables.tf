variable "slack_bot_token" {
  type = string

  description = "Bot User OAuth Token. Can be found in Settings > Install App."
}

variable "default_workspace" {
  type = string

  description = "Default workspace when slack does not send it in events"
}
