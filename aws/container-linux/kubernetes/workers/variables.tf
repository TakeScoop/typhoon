variable "cluster_name" {
  type        = string
  description = "Name of the cluster the workers belong to"
}

variable "name" {
  type        = string
  description = "Unique name for the worker pool"
}

# AWS

variable "vpc_id" {
  type        = string
  description = "Must be set to `vpc_id` output by cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Must be set to `subnet_ids` output by cluster"
}

variable "security_groups" {
  type        = list(string)
  description = "Must be set to `worker_security_groups` output by cluster"
}

# instances

variable "worker_count" {
  type        = number
  description = "Number of instances"
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.small"
}

variable "os_image" {
  type        = string
  description = "AMI channel for a Container Linux derivative (coreos-stable, coreos-beta, coreos-alpha, flatcar-stable, flatcar-beta, flatcar-alpha, flatcar-edge)"
  default     = "flatcar-stable"
}

variable "disk_size" {
  type        = number
  description = "Size of the EBS volume in GB"
  default     = 40
}

variable "disk_type" {
  type        = string
  description = "Type of the EBS volume (e.g. standard, gp2, io1)"
  default     = "gp2"
}

variable "disk_iops" {
  type        = number
  description = "IOPS of the EBS volume (required for io1)"
  default     = 0
}

variable "spot_price" {
  type        = number
  description = "Spot price in USD for worker instances or 0 to use on-demand instances"
  default     = 0
}

variable "target_groups" {
  type        = list(string)
  description = "Additional target group ARNs to which instances should be added"
  default     = []
}

variable "snippets" {
  type        = list(string)
  description = "Container Linux Config snippets"
  default     = []
}

# configuration

variable "kubeconfig" {
  type        = string
  description = "Must be set to `kubeconfig` output by cluster"
}

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for coredns.
EOD
  default     = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  type        = string
  description = "Queries for domains with the suffix will be answered by coredns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  default     = "cluster.local"
}

variable "node_labels" {
  type        = list(string)
  description = "List of initial node labels"
  default     = []
}

# Scoop variables

variable "ami" {
  type        = string
  description = "Custom AMI to use for launching workers (defaults to latest stable CoreOS)"
  default     = ""
}

variable "ignition_config_bucket" {
  type        = "string"
  description = "The name of S3 bucket that stores ignition configs for bastion, controllers and workers"
}
