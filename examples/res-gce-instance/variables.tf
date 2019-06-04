variable "region" {
  default = "australia-southeast1"
}

variable "credentials_file_path" {
  description = "Location of the credentials to use."
  default     = "~/.config/gcloud/terraform-admin.json"
}

variable "project_id" {
  description = "Service Project ID"
}

variable "host_project_id" {
  description = "Shared VPC Host Project ID"
}