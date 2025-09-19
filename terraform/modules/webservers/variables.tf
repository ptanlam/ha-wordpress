variable "name" {
  description = "Name of the web server"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the web server will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of web server instances"
  type        = number
}

variable "max_size" {
  description = "Maximum number of web server instances"
  type        = number
}

variable "min_size" {
  description = "Minimum number of web server instances"
  type        = number
}

variable "instance_profile_name" {
  description = "IAM instance profile name for the web server instances"
  type        = string

}
