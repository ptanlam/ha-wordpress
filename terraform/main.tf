module "ansible_playbook_bucket" {
  source = "./modules/ansible_playbook_bucket"

  name            = "ha-wordpress-playbook-${var.environment}"
  replica_enabled = var.playbook_bucket.replica_enabled

  providers = {
    aws.main    = aws.use1
    aws.replica = aws.usw1
  }
}
