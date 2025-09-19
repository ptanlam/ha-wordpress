output "ansible_playbook_bucket_name" {
  value = module.ansible_playbook_bucket.s3_bucket_id
}

output "ansible_playbook_bucket_replica_name" {
  value = module.ansible_playbook_bucket_replica.s3_bucket_id

}

output "image_builder_logs_bucket_name" {
  value = module.image_builder_logs_bucket.s3_bucket_id
}
