variable "org_id" {
  description = "The ID of the Google Cloud Organization"
}

variable "admin_project_id" {
  description = "The ID of the Admin Project"
}

variable "region" {
  description = "The Region to interface with the Google API and deploy Resources"
  default = "australia-southeast1"
}

variable "credentials_file_path" {
  description = "Location of the Google Cloud Platform credentials"
  default     = "~/.config/gcloud/terraform-admin.json"
}

variable "credentials_gsuite_file_path" {
  description = "Location of the GSuite credentials"
  default     = "~/.config/gsuite/terraform-gsuite.json"
}

variable "credentials_gsuite_impersonated_user_email" {
  description = "Email address of the GSuite credentials to impersonate"
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}

variable "images_project_id" {
  description = "Images Project ID"
}