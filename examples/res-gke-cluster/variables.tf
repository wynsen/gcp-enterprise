variable "region" {
  default = "australia-southeast1"
}

variable "credentials_file_path" {
  description = "Location of the Google Cloud Platform credentials"
  default     = "~/.config/gcloud/terraform-admin.json"
}

variable "project_id" {
  description = "Service Project ID"
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}