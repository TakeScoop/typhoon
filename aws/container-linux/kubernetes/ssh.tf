locals {
  # format assets for distribution
  assets_bundle = [
    # header with the unpack location
    for key, value in module.bootstrap.assets_dist :
    format("##### %s\n%s", key, value)
  ]
}

# Secure copy assets to controllers.
resource "null_resource" "copy-controller-secrets" {
  count = var.controller_count

  depends_on = [
    aws_autoscaling_group.bastion,
    module.bootstrap,
  ]

  connection {
    type = "ssh"

    host = aws_instance.controllers.*.private_ip[count.index]
    user = var.ssh_user

    bastion_host = aws_lb.bastion.dns_name
    bastion_user = var.ssh_user

    timeout = "15m"
  }

  provisioner "file" {
    content     = join("\n", local.assets_bundle)
    destination = "$HOME/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/bootstrap/layout",
    ]
  }
}

# Connect to a controller to perform one-time cluster bootstrap.
resource "null_resource" "bootstrap" {
  depends_on = [
    null_resource.copy-controller-secrets,
    module.workers,
    aws_route53_record.apiserver,
  ]

  connection {
    type = "ssh"

    host = aws_instance.controllers[0].private_ip
    user = var.ssh_user

    bastion_host = aws_lb.bastion.dns_name
    bastion_user = var.ssh_user

    timeout = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start bootstrap",
    ]
  }
}

