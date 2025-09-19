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
    cidr         = string
    azs          = list(string)
    failover_azs = list(string)

    private_subnets  = list(string)
    public_subnets   = list(string)
    database_subnets = list(string)

    enable_nat_gateway     = bool
    one_nat_gateway_per_az = bool
  })
}

variable "database" {
  type = object({
    instance_class    = string
    allocated_storage = number
    db_name           = string
    username          = string
    password          = string
  })
  description = "Database configuration"
}

variable "webserver" {
  type = object({
    instance_type    = string
    desired_capacity = number
    max_size         = number
    min_size         = number
  })
  description = "Web server configuration"
}

variable "dns_name" {
  type        = string
  description = "The DNS name for the application (e.g., example.com)"
}
