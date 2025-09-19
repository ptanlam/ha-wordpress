output "main_db_host" {
  description = "The database endpoint"
  value       = module.master.db_instance_address
}

output "replica_db_host" {
  description = "The read replica database endpoint"
  value       = module.replica.db_instance_address
}
