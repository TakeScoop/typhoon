output "ingress_dns_name" {
  value       = "${aws_lb.ingress.dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}

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