data "aws_region" "current" {}

data "aws_route53_zone" "internal" {
  name = "k8s-playground.takescoop.com"
}

provider "aws" {
  region = "us-east-1"
}

module "kubernetes" {
  source = "./aws/container-linux/kubernetes"

  dns_zone    = "k8s-playground.takescoop.com"
  dns_zone_id = "${data.aws_route53_zone.internal.zone_id}"

  ssh_authorized_key = "key"

  cluster_name     = "bastion-test"
  controller_count = 2
  worker_count     = 2

  asset_dir = "./output"
}
