variable "region" {
  description = "The Region to interface with the Google API and deploy Resources"
  default     = "australia-southeast1"
}

variable "instance_id" {
  description = "(Optional) Asset Instance ID"
  default     = ""
}

variable "project_id" {
  description = "Service Project ID"
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}

variable "subnet_name" {
  description = "Subnet to attach the Virtual Machine instance"
}

variable "preemptible" {
  description = "(Optional) Preemptible option for Virtual Machine instance (default: false)"
  default     = false
}

variable "machine_type" {
  description = "(Optional) Machine Type employed in the GKE Cluster (default: n1-standard-1)"
  default     = "n1-standard-1"
}

variable "image_project" {
  description = "Project containing the Image Family used for the VM Instance (default: ubuntu-os-cloud)"
  default     = "ubuntu-os-cloud"
}

variable "image_family" {
  description = "Image Family used for the VM Instance (default: ubuntu-1604-lts)"
  default     = "ubuntu-1604-lts"
}

variable "disk_size" {
  description = "Root disk volume size (GB) on each node (default: 30)"
  default     = 30
}

variable "disk_type" {
  description = "Disk type (pd-ssd, local-ssd, pd-standard - default: pd-standard)"
  default     = "pd-standard"
}

variable "cluster_size" {
  description = "Number of nodes to have in the Consul cluster. (3 or 5, default: 3)"
  default     = 3
}

variable "custom_metadata" {
  description = "Map of metadata key value pairs to assign to the Compute Instance metadata"
  type        = "map"
  default     = {}
}