output "kubeconfig-admin" {
  value = module.bootstrap.kubeconfig-admin
}

# Outputs for Kubernetes Ingress

output "ingress_dns_name" {
  value       = aws_lb.nlb.dns_name
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}

output "ingress_zone_id" {
  value       = aws_lb.nlb.zone_id
  description = "Route53 zone id of the network load balancer DNS name that can be used in Route53 alias records"
}

# Outputs for worker pools

output "vpc_id" {
  value       = aws_vpc.network.id
  description = "ID of the VPC for creating worker instances"
}

output "private_subnet_ids" {
  value       = aws_subnet.private.*.id
  description = "List of private subnet IDs"
}

output "public_subnet_ids" {
  value       = aws_subnet.public.*.id
  description = "List of public subnet IDs"
}

output "worker_security_groups" {
  value       = [aws_security_group.worker.id]
  description = "List of worker security group IDs"
}

output "kubeconfig" {
  value = module.bootstrap.kubeconfig-kubelet
}

output "kube_ca" {
  description = "Base64-encoded CA cert data for Kubernetes apiserver"
  value       = module.bootstrap.ca_cert
}

# Outputs for custom load balancing

output "nlb_id" {
  description = "ARN of the Network Load Balancer"
  value       = aws_lb.nlb.id
}

output "worker_target_group_http" {
  description = "ARN of a target group of workers for HTTP traffic"
  value       = module.workers.target_group_http
}

output "worker_target_group_https" {
  description = "ARN of a target group of workers for HTTPS traffic"
  value       = module.workers.target_group_https
}

# Outputs for debug

output "assets_dist" {
  value = module.bootstrap.assets_dist
}

# Scoop outputs

output "bastion_dns_name" {
  value       = aws_lb.bastion.dns_name
  description = "DNS name of the network load balancer for distributing traffic to bastion hosts"

  depends_on = [
    aws_autoscaling_group.bastion
  ]
}

output "apiserver_dns_name" {
  value       = aws_route53_record.apiserver.fqdn
  description = "DNS name of the Route53 record used to access the Kubernetes apiserver"
}

output "bootstrap_controller_ip" {
  value       = aws_instance.controllers.0.private_ip
  description = "IP address of the controller instance used to bootstrap the cluster"
}

output "nat_ips" {
  value       = aws_eip.nat.*.public_ip
  description = "List of NAT IPs where public traffic from this cluster will originate"
}

output "private_route_tables" {
  value       = aws_route_table.private.*.id
  description = "IDs of the private route tables that can be used to add additional private routes"
}

output "private_route_tables_count" {
  value       = length(aws_route_table.private)
  description = "Number of private route tables that are created"
}

output "public_route_tables" {
  value       = aws_route_table.public.*.id
  description = "IDs of the public route tables"
}

output "public_route_tables_count" {
  value       = length(aws_route_table.public)
  description = "Number of public route tables that are created"
}

output "depends_id" {
  value       = null_resource.bootstrap.id
  description = "Resource ID that will be defined when the cluster is ready"
}

output "controller_role" {
  value       = aws_iam_role.controller.arn
  description = "Instance role ARN attached to controller instances via instance profile"
}

output "worker_role" {
  value       = module.workers.instance_role
  description = "Instance role ARN attached to worker instances via instance profile"
}

output "worker_autoscaling_group" {
  value       = module.workers.autoscaling_group
  description = "Name of the workers autoscaling group"
}
