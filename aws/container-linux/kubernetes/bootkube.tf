# Self-hosted Kubernetes assets (kubeconfig, manifests)
module "bootkube" {
<<<<<<< HEAD
  source = "git::https://github.com/takescoop/terraform-render-bootkube.git?ref=9f8f95f51258229d1ff37afcf0b8355a001f7ef9"
=======
  source = "git::https://github.com/poseidon/terraform-render-bootkube.git?ref=e892e291b572655699aee8565c14c8446bab2104"
>>>>>>> poseidon/master

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
  
  enable_reporting      = "${var.enable_reporting}"

  # scoop

  apiserver_port        = "${var.apiserver_port}"
  apiserver_arguments   = "${var.apiserver_arguments}"

}
