variable "name" {
  description = "The domain name for the Route 53 hosted zone"
  type        = string
}

variable "main_alb_dns" {
  description = "The DNS name of the main ALB"
  type        = string
}

variable "main_alb_zone_id" {
  description = "The hosted zone ID of the main ALB"
  type        = string
}

variable "failover_alb_dns" {
  description = "The DNS name of the failover ALB"
  type        = string
}

variable "failover_alb_zone_id" {
  description = "The hosted zone ID of the failover ALB"
  type        = string
}
