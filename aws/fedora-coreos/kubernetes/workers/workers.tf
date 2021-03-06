locals {
  user_data_worker = {
    ignition = {
      version = "3.1.0"
      config = {
        merge = [
          {
            source = var.base_ignition_config_path
          },
          {
            source = "s3://${var.ignition_config_bucket}/${aws_s3_bucket_object.worker-ignition.id}"
          }
        ]
      }
    }
  }
}

# Workers AutoScaling Group
resource "aws_autoscaling_group" "workers" {
  name = "${var.name}-worker ${aws_launch_configuration.worker.name}"

  # count
  desired_capacity          = var.worker_count
  min_size                  = var.worker_count
  max_size                  = var.worker_count + 2
  default_cooldown          = 30
  health_check_grace_period = 30

  # network
  vpc_zone_identifier = var.subnet_ids

  # template
  launch_configuration = aws_launch_configuration.worker.name

  # target groups to which instances should be added
  # removed due to conflict with aws_autoscaling_attachment, also unused
  # target_group_arns = flatten([
  #   aws_lb_target_group.workers-http.id,
  #   aws_lb_target_group.workers-https.id,
  #   var.target_groups,
  # ])

  lifecycle {
    # override the default destroy and replace update behavior
    create_before_destroy = true
  }

  # Waiting for instance creation delays adding the ASG to state. If instances
  # can't be created (e.g. spot price too low), the ASG will be orphaned.
  # Orphaned ASGs escape cleanup, can't be updated, and keep bidding if spot is
  # used. Disable wait to avoid issues and align with other clouds.
  wait_for_capacity_timeout = "0"

  tags = [
    {
      key                 = "Name"
      value               = "${var.name}-worker"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
  ]
}

# Worker template
resource "aws_launch_configuration" "worker" {
  image_id          = coalesce(var.ami, data.aws_ami.fedora-coreos.image_id)
  instance_type     = var.instance_type
  spot_price        = var.spot_price > 0 ? var.spot_price : null
  enable_monitoring = false

  user_data = jsonencode(local.user_data_worker)

  # storage
  root_block_device {
    volume_type = var.disk_type
    volume_size = var.disk_size
    iops        = var.disk_iops
    encrypted   = true
  }

  # network
  security_groups = var.security_groups

  # iam
  iam_instance_profile = aws_iam_instance_profile.worker.name

  lifecycle {
    // Override the default destroy and replace update behavior
    create_before_destroy = true
    ignore_changes        = [image_id, user_data]
  }
}

resource "aws_s3_bucket_object" "worker-ignition" {
  bucket  = var.ignition_config_bucket
  key     = "worker.json"
  content = data.ct_config.worker-ignition.rendered
}

# Worker Ignition config
data "ct_config" "worker-ignition" {
  content  = data.template_file.worker-config.rendered
  strict   = true
  snippets = var.snippets
}

# Worker Fedora CoreOS config
data "template_file" "worker-config" {
  template = file("${path.module}/fcc/worker.yaml")

  vars = {
    kubeconfig             = indent(10, var.kubeconfig)
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
    node_labels            = join(",", var.node_labels)
  }
}

resource "aws_iam_role_policy" "worker_read_base_ignition_config" {
  name   = "read-base-ignition-config"
  role   = aws_iam_role.worker.id
  policy = var.base_ignition_config_read_policy
}

resource "aws_iam_role_policy" "worker_read_ignition_configs" {
  name   = "read-ignition-configs"
  role   = aws_iam_role.worker.id
  policy = data.aws_iam_policy_document.worker_read_ignition_configs.json
}

data "aws_iam_policy_document" "worker_read_ignition_configs" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.ignition_config_bucket}/${aws_s3_bucket_object.worker-ignition.id}"]
  }
}

resource "aws_iam_role_policy" "worker_instance_read_ec2" {
  name   = "instance-read-ec2"
  role   = aws_iam_role.worker.id
  policy = data.aws_iam_policy_document.worker_instance_read_ec2.json
}

data "aws_iam_policy_document" "worker_instance_read_ec2" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker" {
  name               = "${var.name}-worker"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.name}-worker"
  role = aws_iam_role.worker.id
}
