resource "aws_security_group" "main" {
  name        = "${var.identifier}-db-sg"
  description = "Security group for RDS instance ${var.identifier}"
  vpc_id      = var.main_networking.vpc_id

  provider = aws.main
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_main" {
  security_group_id = aws_security_group.main.id

  ip_protocol = "-1"
  cidr_ipv4   = var.main_networking.vpc_cidr

  provider = aws.main
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_inbound_main" {
  security_group_id = aws_security_group.main.id

  from_port   = local.port
  to_port     = local.port
  ip_protocol = "tcp"
  cidr_ipv4   = var.main_networking.vpc_cidr

  provider = aws.main
}


resource "aws_security_group" "replica" {
  name        = "${var.identifier}-db-sg"
  description = "Security group for RDS instance ${var.identifier}"
  vpc_id      = var.replica_networking.vpc_id

  provider = aws.replica
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_replica" {
  security_group_id = aws_security_group.replica.id

  ip_protocol = "-1"
  cidr_ipv4   = var.replica_networking.vpc_cidr

  provider = aws.replica
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_inbound_replica" {
  security_group_id = aws_security_group.replica.id

  from_port   = local.port
  to_port     = local.port
  ip_protocol = "tcp"
  cidr_ipv4   = var.replica_networking.vpc_cidr

  provider = aws.replica
}
