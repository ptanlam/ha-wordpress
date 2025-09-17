variable "environment" {
  type        = string
  description = "Environment"
}


variable "playbook_bucket" {
  type = object({
    replica_enabled = bool
  })

  description = "Ansible playbooks bucket configuration"

  default = {
    replica_enabled = false
  }
}
