variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name (prepended to dns_zone)"
}

# AWS

variable "dns_zone" {
  type        = "string"
  description = "AWS Route53 DNS Zone (e.g. aws.example.com)"
}

variable "dns_zone_id" {
  type        = "string"
  description = "AWS Route53 DNS Zone ID (e.g. Z3PAABBCFAKEC0)"
}

# instances

variable "controller_count" {
  type        = "string"
  default     = "1"
  description = "Number of controllers (i.e. masters)"
}

variable "worker_count" {
  type        = "string"
  default     = "1"
  description = "Number of workers"
}

variable "controller_type" {
  type        = "string"
  default     = "t2.small"
  description = "EC2 instance type for controllers"
}

variable "worker_type" {
  type        = "string"
  default     = "t2.small"
  description = "EC2 instance type for workers"
}

variable "os_channel" {
  type        = "string"
  default     = "stable"
  description = "Container Linux AMI channel (stable, beta, alpha)"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "Size of the EBS volume in GB"
}

variable "disk_type" {
  type        = "string"
  default     = "gp2"
  description = "Type of the EBS volume (e.g. standard, gp2, io1)"
}

variable "controller_clc_snippets" {
  type        = "list"
  description = "Controller Container Linux Config snippets"
  default     = []
}

variable "worker_clc_snippets" {
  type        = "list"
  description = "Worker Container Linux Config snippets"
  default     = []
}

variable "bastion_clc_snippets" {
  type        = "list"
  description = "Bastion Container Linux Config snippets"
  default     = []
}

# configuration

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "networking" {
  description = "Choice of networking provider (calico or flannel)"
  type        = "string"
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only). Use 8981 if using instances types with Jumbo frames."
  type        = "string"
  default     = "1480"
}

variable "host_cidr" {
  description = "CIDR IPv4 range to assign to EC2 nodes"
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by kube-dns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}

# Scoop variables

variable "apiserver_aliases" {
  type = "list"
  description = "List of alternate DNS names that can be used to address the Kubernetes API"
  default = []
}

variable "apiserver_arguments" {
  type = "list"
  default = []
  description = "Custom arguments to pass to the kube-apiserver"
}

variable "bastion_type" {
  type        = "string"
  default     = "t2.micro"
  description = "Bastion EC2 instance type"
}

variable "bastion_count" {
  type        = "string"
  default     = "1"
  description = "Number of bastion hosts to run"
}

variable "amis" {
  description = "Static AMIs to use for different cluster roles. When no value is set for a role, the latest stable CoreOS AMI is used"
  type        = "map"
  # assign an empty string value so terraform can detect the value type for the map
  default     = {"" = ""}
}

variable "worker_role" {
  type = "string"
  description = "IAM role to assign to worker nodes (defaults to none)"
  default = ""
}

variable "ssh_user" {
  type = "string"
  description = "Username for provisioning via SSH"
}

variable "ca_cert" {
  description = "Existing PEM-encoded CA certificate (generated if blank)"
  type        = "string"
  default     = ""
}

variable "ca_algorithm" {
  description = "Algorithm used to generate ca_key (required if ca_cert is specified)"
  type        = "string"
  default     = "RSA"
}

variable "ca_key" {
  description = "Existing Certificate Authority private key (required if ca_certificate is set)"
  type        = "string"
  default     = ""
}

variable "subnet_tags_private" {
  type = "map"
  description = "Tags to apply to private subnets"
  default = {}
}

variable "subnet_tags_public" {
  type = "map"
  description = "Tags to apply to public subnets"
  default = {}
}
