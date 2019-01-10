output "kubeconfig-admin" {
  value = "${module.bootkube.kubeconfig-admin}"
}

# Outputs for Kubernetes Ingress

output "ingress_dns_name" {
  value       = "${aws_lb.nlb.dns_name}"
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
  value = "${module.bootkube.kubeconfig-kubelet}"
}

# Outputs for custom load balancing

output "worker_target_group_http" {
  description = "ARN of a target group of workers for HTTP traffic"
  value       = "${module.workers.target_group_http}"
}

output "worker_target_group_https" {
  description = "ARN of a target group of workers for HTTPS traffic"
  value       = "${module.workers.target_group_https}"
}

# Scoop outputs

output "bastion_dns_name" {
  value       = "${aws_lb.bastion.dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to bastion hosts"
}

output "apiserver_dns_name" {
  value       = "${aws_route53_record.apiserver.fqdn}"
  description = "DNS name of the Route53 record used to access the Kubernetes apiserver"
}

output "bootstrap_controller_ip" {
  value       = "${aws_instance.controllers.0.private_ip}"
  description = "IP address of the controller instance used to bootstrap the cluster"
}

output nat_ips {
  value       = ["${aws_eip.nat.*.public_ip}"]
  description = "List of NAT IPs where public traffic from this cluster will originate"
}

output "private_route_tables" {
  value       = ["${aws_route_table.private.*.id}"]
  description = "ID of the private route table that can be used to add additional private routes"
}

output "depends_id" {
  value       = "${null_resource.bootkube-start.id}"
  description = "Resource ID that will be defined when the cluster is ready"
}

output "controller_role" {
  value       = "${aws_iam_role.controller.arn}"
  description = "Instance role ARN attached to controller instances via instance profile"
}

output "worker_role" {
  value       = "${module.workers.instance_role}"
  description = "Instance role ARN attached to worker instances via instance profile"
}