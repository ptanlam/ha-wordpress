variable "name_prefix" {
  type        = string
  description = "Application name"
}

variable "playbook_bucket" {
  type = string
}

variable "playbook_bucket_replica" {
  type = string
}

variable "playbook_bucket_logs" {
  type = string
}
