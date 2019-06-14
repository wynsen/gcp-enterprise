variable "company_id" {
  description = "Company ID (e.g. 3-letter code)"
}

variable "asset_id" {
  description = "Asset ID (e.g. same ID as in Asset Management System)"
}

variable "component_id" {
  description = "Asset Component ID (e.g. containers)"
}

variable "environment_id" {
  description = "(Optional) Asset Environment ID (e.g. dev)"
  default     = ""
}

variable "instance_id" {
  description = "(Optional) Asset Instance ID"
  default     = ""
}

variable "region" {
  description = "The Region to interface with the Google API and deploy Resources"
  default = "australia-southeast1"
}

variable "org_id" {
  description = "The ID of the Organization to create the Project in (only org_id or folder_id to be provided)"
  default = ""
}

variable "folder_id" {
  description = "The ID of the Folder to create the Project in (only org_id or folder_id to be provided)"
  default = ""
}
variable "billing_account_id" {
  description = "The ID of the billing account to associate the Project with"
}

variable "project_id_suffix" {
  description = "(Optional) Append a random 6 hexadecimal suffix to the Project Name for the Project ID (Default: true)"
  default = true
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}

variable "terraform_delegate_email" {
  description = "Terraform Account delegated to the Folder (Email format)"
}

variable "editor_group_email" {
  description = "Editor Group associated with the Folder (Email format)"
}

variable "shared_network_name" {
  description = "Shared VPC Network Name"
}

variable "ipv4_range_primary" {
  description = "Subnet IPv4 Range (CIDR) Primary (e.g. /27 for GKE)"
}

variable "ipv4_range_secondary0" {
  description = "Subnet IPv4 Range (CIDR) Secondary 0 (e.g. /19 for GKE)"
}

variable "ipv4_range_secondary1" {
  description = "Subnet IPv4 Range (CIDR) Secondary 1 (e.g. /24 for GKE)"
}

variable "subnet_flow_logs" {
  description = "(Optional) Enable Flow Logging for the Subnet (Default: false)"
  default = false
}