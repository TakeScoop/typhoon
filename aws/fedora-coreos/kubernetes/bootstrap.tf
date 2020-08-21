# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/takescoop/terraform-render-bootstrap.git?ref=d3132edba9f84ad210376f0632d435c08d6ce3e4"

  cluster_name          = var.cluster_name
  api_servers           = concat(list(format("%s.%s", var.cluster_name, var.dns_zone)), var.apiserver_aliases)
  etcd_servers          = aws_route53_record.etcds.*.fqdn
  asset_dir             = var.asset_dir
  networking            = var.networking
  network_mtu           = var.network_mtu
  pod_cidr              = var.pod_cidr
  service_cidr          = var.service_cidr
  cluster_domain_suffix = var.cluster_domain_suffix
  enable_reporting      = var.enable_reporting
  enable_aggregation    = var.enable_aggregation

  trusted_certs_dir = "/etc/pki/tls/certs"

  # scoop
  apiserver_arguments = var.apiserver_arguments
}

