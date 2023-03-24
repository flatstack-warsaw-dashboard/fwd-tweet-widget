variable "messages_table_name" {
  type = string
}

variable "messages_table_arn" {
  type = string
}

variable "workspace_name" {
  type = string

  description = "Which workspace messages are shown in API response"
}
