variable "environment" {
  type        = string
  description = "Environment"
}

variable "region" {
  type = object({
    main     = string
    failover = optional(string)
  })

  description = "Active regions"
}

variable "app_name" {
  type        = string
  description = "Application name"
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

variable "vpc" {
  type = object({
    cidr = string
    azs  = list(string)

    private_subnets  = list(string)
    public_subnets   = list(string)
    database_subnets = list(string)

    enable_nat_gateway     = bool
    one_nat_gateway_per_az = bool
  })
}
