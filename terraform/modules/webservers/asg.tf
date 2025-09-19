resource "aws_security_group" "this" {
  name = "${var.name}-webserver-sg"

  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.this.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_http" {
  security_group_id = aws_security_group.this.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  referenced_security_group_id = module.alb.security_group_id
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.1"

  # Autoscaling group
  name = "${var.name}-asg"

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.private_subnets

  # Launch template
  launch_template_name        = "${var.name}-lt"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = data.aws_ami.this.id
  instance_type     = var.instance_type
  ebs_optimized     = true
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = false
  iam_instance_profile_name   = var.instance_profile_name

  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 100
        volume_type           = "gp2"
      }
    }
  ]
  # This will ensure imdsv2 is enabled, required, and a single hop which is aws security
  # best practices
  # See https://docs.aws.amazon.com/securityhub/latest/userguide/autoscaling-controls.html#autoscaling-4
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  security_groups = [aws_security_group.this.id]
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = module.asg.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}
