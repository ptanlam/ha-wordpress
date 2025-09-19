variable "identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
}

variable "username" {
  description = "The master username for the database"
  type        = string
}

variable "password" {
  description = "The master password for the database"
  type        = string
}

variable "main_networking" {
  type = object({
    vpc_id     = string
    vpc_cidr   = string
    subnet_ids = list(string)
  })
}

variable "replica_networking" {
  type = object({
    vpc_id     = string
    vpc_cidr   = string
    subnet_ids = list(string)
  })
}
