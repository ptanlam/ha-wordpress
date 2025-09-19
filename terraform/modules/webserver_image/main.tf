resource "aws_imagebuilder_component" "this" {
  data = yamlencode({
    phases = [{
      name = "build"
      steps = [
        {
          name   = "InstallAnsible"
          action = "ExecuteBash"
          inputs = {
            commands = [
              "sudo dnf update -y",
              "sudo dnf install -y python3 python3-pip ansible"
            ]
          }
        },
        {
          name   = "DownloadPlaybook"
          action = "S3Download"
          inputs = [
            {
              source      = "s3://${var.playbook_bucket}/*",
              destination = "/tmp/playbook"
            }
          ]
        },
        {
          name   = "InvokeAnsible"
          action = "ExecuteBash"
          inputs = {
            commands = [
              "ansible-playbook -i {{build.DownloadPlaybook.inputs[0].destination}}/inventory -e 'rds_endpoint=${var.db_host} rds_db_name=${var.db_name} rds_db_user=${var.db_user} rds_db_password=${var.db_password}' {{build.DownloadPlaybook.inputs[0].destination}}/wordpress-install.yml"
            ]
          }
        },
        {
          name   = "DeletePlaybook"
          action = "ExecuteBash"
          inputs = {
            commands = ["rm -rf '{{build.DownloadPlaybook.inputs[0].destination}}'"]
          }
        }
      ]
    }]
    schemaVersion = 1.0
  })
  name     = "${var.name} Ansible Playbook Execution"
  platform = "Linux"
  version  = "1.0.0"
}

resource "aws_imagebuilder_image_recipe" "this" {
  block_device_mapping {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 100
      volume_type           = "gp3"
    }
  }

  component {
    component_arn = aws_imagebuilder_component.this.arn
  }

  name         = var.name
  parent_image = "arn:${data.aws_partition.current.partition}:imagebuilder:${data.aws_region.current.region}:aws:image/amazon-linux-2023-x86/x.x.x"
  version      = "1.0.0"
}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  instance_profile_name         = var.instance_profile_name
  instance_types                = ["t2.nano", "t3.micro"]
  name                          = var.name
  security_group_ids            = [aws_security_group.this.id]
  subnet_id                     = element(var.private_subnets, 0)
  terminate_instance_on_failure = true

  logging {
    s3_logs {
      s3_bucket_name = var.logging_bucket_name
      s3_key_prefix  = "${data.aws_region.current.region}/logs"
    }
  }
}

resource "aws_imagebuilder_image_pipeline" "this" {
  name = var.name

  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn

  lifecycle {
    replace_triggered_by = [
      aws_imagebuilder_image_recipe.this
    ]
  }
}
