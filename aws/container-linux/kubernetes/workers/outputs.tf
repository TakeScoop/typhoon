output "ingress_dns_name" {
  value       = "${aws_lb.ingress.dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}

output "instance_role" {
  value       = "${aws_iam_role.worker.arn}"
  description = "IAM role ARN attached to instances via instance profile"
}
