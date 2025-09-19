resource "aws_security_group" "this" {
  name   = local.resource_name
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
