output "target_group_http" {
  description = "ARN of a target group of workers for HTTP traffic"
  value       = "${aws_lb_target_group.workers-http.arn}"
}

output "target_group_https" {
  description = "ARN of a target group of workers for HTTPS traffic"
  value       = "${aws_lb_target_group.workers-https.arn}"
}

output "instance_role" {
  value       = "${aws_iam_role.worker.arn}"
  description = "IAM role ARN attached to instances via instance profile"
}

output "autoscale_group_name" {
  value       = "${aws_autoscaling_group.workers.name}"
  description = "Name of the workers autoscale group"
}
