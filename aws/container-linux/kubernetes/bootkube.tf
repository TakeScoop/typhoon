# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/takescoop/terraform-render-bootkube.git?ref=f4e60e23c60acef1a090a0b16f7726620ef6426a"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${concat(list(format("%s.%s", var.cluster_name, var.dns_zone)), var.apiserver_aliases)}"]
  etcd_servers          = ["${aws_route53_record.etcds.*.fqdn}"]
  asset_dir             = "${var.asset_dir}"
  networking            = "${var.networking}"
  network_mtu           = "${var.network_mtu}"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"

  create_ca             = "${var.create_ca}"
  ca_certificate        = "${var.ca_cert}"
  ca_key_alg            = "${var.ca_algorithm}"
  ca_private_key        = "${var.ca_key}"

  apiserver_arguments   = "${var.apiserver_arguments}"
  
  enable_reporting      = "${var.enable_reporting}"
}
