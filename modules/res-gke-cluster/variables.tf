variable "region" {
  description = "The Region to interface with the Google API and deploy Resources"
  default     = "australia-southeast1"
}

variable "location" {
  description = "The Region or Zone to deploy a Regional or Zonal GKE Cluster in respectively"
}

variable "project_id" {
  description = "Service Project ID"
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}

variable "subnet_name" {
  description = "Subnet Name"
}

variable "ipv4_range_master" {
  description = "Subnet IPv4 Range (CIDR) Master"
}

variable "preemptible" {
  description = "(Optional) Virtual Machine instances mployed in the GKE Cluster are preemptible (default: false)"
  default     = false
}

variable "machine_type" {
  description = "(Optional) Machine Type employed in the GKE Cluster (default: n1-standard-1)"
  default     = "n1-standard-1"
}

variable "private_master_only" {
  description = "(Optional) Ensure Master Authorized Networks contains only RFC1918 addresses (default: false)"
  default     = false
}

# Works only with Terraform 0.11
variable "master_authorized_networks_cidr_blocks" {
  description = "Master Authorized CIDR Blocks"
  default     = []
}

# Works with Terraform 0.12
variable "master_authorized_network1_cidr_block" {
  description = "Master Authorized Network 1 CIDR Block"
}

# Works with Terraform 0.12
variable "master_authorized_network1_display_name" {
  description = "Master Authorized Network 1 Display Name"
}

variable "max_pods_per_node" {
  description = "(Optional) Maximum number of Pods per Node in the GKE Cluster (default: 110)"
  default     = 110
}

variable "service_account" {
  description = "(Optional) The Service Account used by the Node VMs (default: default)"
  default     = "default"
}

variable "oauth_scopes" {
  description = "Google API scopes available to Node VMs under the Default Service Account"
  default     = ["storage-ro", "logging-write", "monitoring"]
}

variable "max_node_count" {
  description = "(Optional) Maximum number of Nodes in the Autoscaling GKE Cluster (default: 10)"
  default     = 10
}

variable "key_ring" {
  description = "Key Ring Name for the GKE Etcd Encryption/Decryption Key"
}

variable "gke_key" {
  description = "Key Name for the GKE Etcd Encryption/Decryption Key"
}