data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_imagebuilder_component" "this" {
  data = yamlencode({
    phases = [{
      name = "build"
      steps = [
        {
          name   = "InstallAnsible"
          action = "ExecuteBash"
          inputs = {
            commands = ["sudo amazon-linux-extras install -y ansible2"]
          }
        },
        {
          name   = "DownloadPlaybook"
          action = "S3Download"
          inputs = [
            {
              source      = "s3://${var.playbook_bucket}",
              destination = "/tmp/playbook"
            }
          ]
        },
        {
          name   = "InvokeAnsible"
          action = "ExecuteBinary"
          inputs = {
            path = "ansible-playbook",
            arguments = [
              "'{{build.DownloadPlaybook.inputs[0].destination}}'/wordpress-install.yml"
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
  parent_image = data.aws_ami.amazon_linux_2023.arn
  version      = "1.0.0"
}

# resource "aws_imagebuilder_infrastructure_configuration" "example" {
#   description                   = "example description"
#   instance_profile_name         = aws_iam_instance_profile.example.name
#   instance_types                = ["t2.nano", "t3.micro"]
#   key_pair                      = aws_key_pair.example.key_name
#   name                          = "example"
#   security_group_ids            = [aws_security_group.example.id]
#   subnet_id                     = aws_subnet.main.id
#   terminate_instance_on_failure = true

#   logging {
#     s3_logs {
#       s3_bucket_name = aws_s3_bucket.example.bucket
#       s3_key_prefix  = "logs"
#     }
#   }

#   tags = {
#     foo = "bar"
#   }
# }
