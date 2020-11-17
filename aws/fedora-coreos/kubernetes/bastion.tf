locals {
  user_data_bastion = {
    ignition = {
      version = "3.1.0"
      config = {
        merge = [
          {
            source = var.base_ignition_config_path
          },
          {
            source = "s3://${aws_s3_bucket.ignition_configs.id}/${aws_s3_bucket_object.bastion_config.id}"
          }
        ]
      }
    }
  }
}

resource "aws_autoscaling_group" "bastion" {
  name = "${var.cluster_name}-bastion ${aws_launch_configuration.bastion.name}"

  # count
  desired_capacity          = var.bastion_count
  min_size                  = var.bastion_count
  max_size                  = var.bastion_count
  default_cooldown          = 30
  health_check_grace_period = 30

  # network
  vpc_zone_identifier = aws_subnet.private.*.id

  # template
  launch_configuration = aws_launch_configuration.bastion.name

  # target groups to which instances should be added
  target_group_arns = [
    aws_lb_target_group.bastion.id
  ]

  min_elb_capacity = 1

  lifecycle {
    # override the default destroy and replace update behavior
    create_before_destroy = true
    ignore_changes        = [launch_configuration]
  }

  tags = [{
    key                 = "Name"
    value               = "${var.cluster_name}-bastion"
    propagate_at_launch = true
  }]
}

resource "aws_launch_configuration" "bastion" {
  image_id      = coalesce(var.ami, data.aws_ami.fedora-coreos.image_id)
  instance_type = var.bastion_type

  user_data = jsonencode(local.user_data_bastion)

  # network
  security_groups = [
    aws_security_group.bastion_external.id
  ]

  # iam
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  lifecycle {
    // Override the default destroy and replace update behavior
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_object" "bastion_config" {
  bucket  = aws_s3_bucket.ignition_configs.id
  key     = "bastion.json"
  content = data.ct_config.bastion_ign.rendered
}

data "ct_config" "bastion_ign" {
  content  = file("${path.module}/fcc/bastion.yaml")
  strict   = true
  snippets = var.bastion_snippets
}

resource "aws_security_group" "bastion_external" {
  name_prefix = "${var.cluster_name}-bastion-external-"
  description = "Allows access to the bastion from the internet"

  vpc_id = aws_vpc.network.id

  tags = {
    Name = "${var.cluster_name}-bastion-external"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "bastion_internal" {
  name_prefix = "${var.cluster_name}-bastion-internal-"
  description = "Allows access to a host from the bastion"

  vpc_id = aws_vpc.network.id

  tags = {
    Name = "${var.cluster_name}-bastion-internal"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.bastion_external.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "bastion" {
  name               = "${var.cluster_name}-bastion"
  load_balancer_type = "network"

  subnets = aws_subnet.public.*.id
}


resource "aws_lb_listener" "bastion" {
  load_balancer_arn = aws_lb.bastion.arn
  protocol          = "TCP"
  port              = "22"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion.arn
  }
}

resource "aws_lb_target_group" "bastion" {
  name        = "${var.cluster_name}-bastion"
  vpc_id      = aws_vpc.network.id
  target_type = "instance"

  protocol = "TCP"
  port     = 22

  health_check {
    protocol = "TCP"
    port     = 22

    healthy_threshold   = 3
    unhealthy_threshold = 3

    interval = 10
  }
}

resource "aws_route53_record" "bastion" {
  depends_on = [aws_autoscaling_group.bastion]

  zone_id = var.dns_zone_id

  name = format("bastion.%s.%s.", var.cluster_name, var.dns_zone)
  type = "A"

  alias {
    name                   = aws_lb.bastion.dns_name
    zone_id                = aws_lb.bastion.zone_id
    evaluate_target_health = false
  }
}

resource "aws_iam_role_policy" "bastion_read_base_ignition_config" {
  name   = "read-base-ignition-config"
  role   = aws_iam_role.bastion.id
  policy = var.base_ignition_config_read_policy
}

resource "aws_iam_role_policy" "bastion_read_ignition_config" {
  name   = "read-ignition-configs"
  role   = aws_iam_role.bastion.id
  policy = data.aws_iam_policy_document.bastion_read_ignition_config.json
}

data "aws_iam_policy_document" "bastion_read_ignition_config" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ignition_configs.arn}/${aws_s3_bucket_object.bastion_config.id}"]
  }
}

resource "aws_iam_role_policy" "bastion_instance_read_ec2" {
  name   = "instance-read-ec2"
  role   = aws_iam_role.bastion.id
  policy = data.aws_iam_policy_document.bastion_instance_read_ec2.json
}

data "aws_iam_policy_document" "bastion_instance_read_ec2" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "bastion_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${var.cluster_name}-bastion"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_role.json
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.cluster_name}-bastion"
  role = aws_iam_role.bastion.id
}
