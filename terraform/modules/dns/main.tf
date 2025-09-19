resource "aws_route53_zone" "this" {
  name = var.name
}

resource "aws_route53_health_check" "main" {
  fqdn              = var.main_alb_dns
  port              = "80"
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "${var.main_alb_dns}-health-check"
  }
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.name
  type    = "A"

  alias {
    name                   = var.main_alb_dns
    zone_id                = var.main_alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "main"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.main.id
}

resource "aws_route53_health_check" "failover" {
  fqdn              = var.failover_alb_dns
  port              = "80"
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "${var.failover_alb_dns}-health-check"
  }
}

resource "aws_route53_record" "failover" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.name
  type    = "A"

  alias {
    name                   = var.failover_alb_dns
    zone_id                = var.failover_alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "failover"

  failover_routing_policy {
    type = "SECONDARY"
  }

  health_check_id = aws_route53_health_check.failover.id
}
