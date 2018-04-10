# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
  source = "git::https://github.com/takescoop/terraform-render-bootkube.git?ref=5eaf6cfc7fa09c511664d72f4b29157980653008"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${format("%s.%s", var.cluster_name, var.dns_zone)}"]
  etcd_servers          = ["${aws_route53_record.etcds.*.fqdn}"]
  asset_dir             = "${var.asset_dir}"
  networking            = "${var.networking}"
  network_mtu           = "${var.network_mtu}"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"

  oidc_issuer_url = "${var.oidc_issuer_url}"
  oidc_client_id = "${var.oidc_client_id}"
  oidc_username_claim = "${var.oidc_username_claim}"
}
