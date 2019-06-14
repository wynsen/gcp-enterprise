variable "region" {
  description = "The Region to interface with the Google API and deploy Resources"
  default     = "australia-southeast1"
}

variable "credentials_file_path" {
  description = "Location of the Google Cloud Platform credentials"
  default     = "~/.config/gcloud/terraform-admin.json"
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}