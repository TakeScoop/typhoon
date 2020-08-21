output "target_group_http" {
  description = "ARN of a target group of workers for HTTP traffic"
  value       = aws_lb_target_group.workers-http.arn
}

output "target_group_https" {
  description = "ARN of a target group of workers for HTTPS traffic"
  value       = aws_lb_target_group.workers-https.arn
}

output "instance_role" {
  description = "IAM role ARN attached to instances via instance profile"
  value       = aws_iam_role.worker.arn
}

output "autoscaling_group" {
  description = "Name of the workers autoscaling group"
  value       = aws_autoscaling_group.workers.name
}

