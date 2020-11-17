# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "aws_route53_record" "etcds" {
  count = var.controller_count

  # DNS Zone where record should be created
  zone_id = var.dns_zone_id

  name = format("%s-etcd%d.%s.", var.cluster_name, count.index, var.dns_zone)
  type = "A"
  ttl  = 300

  # private IPv4 address for etcd
  records = [aws_instance.controllers.*.private_ip[count.index]]
}

# Controller instances
resource "aws_instance" "controllers" {
  count = var.controller_count

  tags = map(
    "Name", "${var.cluster_name}-controller-${count.index}",
    "kubernetes.io/cluster/${var.cluster_name}", "owned"
  )

  instance_type = var.controller_type

  ami                  = coalesce(var.ami, data.aws_ami.fedora-coreos.image_id)
  iam_instance_profile = aws_iam_instance_profile.controller.name

  user_data = <<EOF
{
  "ignition": {
    "version": "3.0.0",
    "config": {
      "merge": [
        {
          "source": "${var.base_ignition_config_path}"
        },
        {
          "source": "s3://${aws_s3_bucket.ignition_configs.id}/${aws_s3_bucket_object.controller-ignitions.*.id[count.index]}"
        }
      ]
    }
  }
}
EOF

  # storage
  root_block_device {
    volume_type = var.disk_type
    volume_size = var.disk_size
    iops        = var.disk_iops
    encrypted   = true
  }

  # network
  subnet_id = element(aws_subnet.private.*.id, count.index)
  vpc_security_group_ids = [
    aws_security_group.controller.id,
    aws_security_group.bastion_internal.id
  ]

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_s3_bucket_object" "controller-ignitions" {
  count   = var.controller_count
  bucket  = aws_s3_bucket.ignition_configs.id
  key     = "controllers/${count.index}.json"
  content = data.ct_config.controller-ignitions.*.rendered[count.index]
}

# Controller Ignition configs
data "ct_config" "controller-ignitions" {
  count    = var.controller_count
  content  = data.template_file.controller-configs.*.rendered[count.index]
  strict   = true
  snippets = var.controller_snippets

  # As for ct@v0.7.0, if pretty_print is set to false, non-empty snippets will empty the rendered Ignition.
  # This is likely a bug of ct provider.
  pretty_print = true
}

# Controller Fedora CoreOS configs
data "template_file" "controller-configs" {
  count = var.controller_count

  template = file("${path.module}/fcc/controller.yaml")

  vars = {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster   = join(",", data.template_file.etcds.*.rendered)
    kubeconfig             = indent(10, module.bootstrap.kubeconfig-kubelet)
    cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
    cluster_domain_suffix  = var.cluster_domain_suffix
  }
}

data "template_file" "etcds" {
  count    = var.controller_count
  template = "etcd$${index}=https://$${cluster_name}-etcd$${index}.$${dns_zone}:2380"

  vars = {
    index        = count.index
    cluster_name = var.cluster_name
    dns_zone     = var.dns_zone
  }
}

resource "aws_iam_role_policy" "controller_read_base_ignition_config" {
  name   = "read-base-ignition-config"
  role   = aws_iam_role.controller.id
  policy = var.base_ignition_config_read_policy
}

resource "aws_iam_role_policy" "controller_read_ignition_configs" {
  name   = "read-ignition-configs"
  role   = aws_iam_role.controller.id
  policy = data.aws_iam_policy_document.controller_read_ignition_configs.json
}

data "aws_iam_policy_document" "controller_read_ignition_configs" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = formatlist("${aws_s3_bucket.ignition_configs.arn}/%s", aws_s3_bucket_object.controller-ignitions.*.id)
  }
}

resource "aws_iam_role_policy" "controller_instance_read_ec2" {
  name   = "instance-read-ec2"
  role   = aws_iam_role.controller.id
  policy = data.aws_iam_policy_document.controller_instance_read_ec2.json
}

data "aws_iam_policy_document" "controller_instance_read_ec2" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "controller_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "controller" {
  name               = "${var.cluster_name}-controller"
  assume_role_policy = data.aws_iam_policy_document.controller_assume_role.json
}

resource "aws_iam_instance_profile" "controller" {
  name = "${var.cluster_name}-controller"
  role = aws_iam_role.controller.id
}
