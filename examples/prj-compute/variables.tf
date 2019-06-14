variable "region" {
  description = "The Region to interface with the Google API and deploy Resources"
  default     = "australia-southeast1"
}

variable "credentials_file_path" {
  description = "Location of the Google Cloud Platform credentials"
  default     = "~/.config/gcloud/terraform-admin.json"
}

variable "folder_id" {
  description = "The ID of the Folder to create the Project in"
}

variable "billing_account_id" {
  description = "The ID of the billing account to associate the Project with"
}

variable "host_project_id" {
  description = "(Optional) Shared VPC Host Project ID"
}

variable "terraform_delegate_email" {
  description = "Terraform Account delegated to the Folder (Email format)"
}

variable "editor_group_email" {
  description = "Editor Group associated with the Folder (Email format)"
}