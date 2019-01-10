module "workers" {
  source = "workers"
  
  cluster_name = "${var.cluster_name}"
  name         = "${var.cluster_name}"

  # AWS
  vpc_id          = "${aws_vpc.network.id}"
  subnet_ids      = ["${aws_subnet.private.*.id}"]
  security_groups = ["${aws_security_group.worker.id}"]
  count           = "${var.worker_count}"
  instance_type   = "${var.worker_type}"
  os_image        = "${var.os_image}"
  disk_size       = "${var.disk_size}"
  spot_price      = "${var.worker_price}"

  # configuration
<<<<<<< HEAD
  kubeconfig            = "${module.bootkube.kubeconfig-kubelet}"
=======
  kubeconfig            = "${module.bootkube.kubeconfig-kubelet}"
  ssh_authorized_key    = "${var.ssh_authorized_key}"
>>>>>>> poseidon/master
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  clc_snippets          = "${var.worker_clc_snippets}"

  # scoop
  ami = "${lookup(var.amis, "worker", "")}"
}
