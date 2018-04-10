output "ingress_dns_name" {
  value       = "${module.workers.ingress_dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}

# Outputs for worker pools

output "vpc_id" {
  value       = "${aws_vpc.network.id}"
  description = "ID of the VPC for creating worker instances"
}

output "subnet_ids" {
  value       = ["${aws_subnet.public.*.id}"]
  description = "List of subnet IDs for creating worker instances"
}

output "worker_security_groups" {
  value       = ["${aws_security_group.worker.id}"]
  description = "List of worker security group IDs"
}

output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}

# Fork outputs

output "bastion_dns_name" {
  value       = "${aws_lb.bastion.dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to bastion hosts"
}

output "bootstrap_controller_ip" {
  value       = "${aws_instance.controllers.0.private_ip}"
  description = "IP address of the controller instance used to bootstrap the cluster"
}

output "depends_id" {
  value       = "${null_resource.bootkube-start.id}"
  description = "Resource ID that will be defined when the cluster is ready"
}
