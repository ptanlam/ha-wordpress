output "bucket_name" {
  value = var.replica_enabled ? module.main_with_replica.s3_bucket_id : module.main.s3_bucket_id
}
