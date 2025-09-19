output "dns_name" {
  description = "The DNS name of the webservers ALB"
  value       = module.alb.dns_name
}


output "zone_id" {
  description = "The hosted zone ID of the webservers ALB"
  value       = module.alb.zone_id
}
