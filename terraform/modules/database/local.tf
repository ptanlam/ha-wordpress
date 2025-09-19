locals {
  port = 3306

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
}
