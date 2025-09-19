data "aws_iam_policy_document" "webserver_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "webserver" {
  name               = "${var.name_prefix}-webserver-role"
  assume_role_policy = data.aws_iam_policy_document.webserver_assume_role.json
}

resource "aws_iam_role_policy_attachment" "webserver_ssm_managed_instance_core" {
  role       = aws_iam_role.webserver.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "webserver" {
  name = "${var.name_prefix}-webserver-instance-profile"

  role = aws_iam_role.webserver.name
}
