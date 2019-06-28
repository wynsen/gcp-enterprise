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

variable "zone" {
  default = "australia-southeast1-a"
  description = "Zone where to deploy the Virtual Machine instance"
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
  description = "Project containing the Image Family used for the VM Instance (default: debian-cloud)"
  default     = "debian-cloud"
}

variable "image_family" {
  description = "Image Family used for the VM Instance (default: debian-9)"
  default     = "debian-9"
}

variable "assign_public_ip" {
  description = "Assign public IP address (default: false)"
  default     = false
}