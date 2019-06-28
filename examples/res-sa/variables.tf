variable "credentials_file_path" {
  description = "Location of the Google Cloud Platform credentials"
  default     = "~/.config/gcloud/terraform-admin.json"
}

variable "project_id" {
  description = "Project ID"
}


variable "vault_url" {
  description = "Vault URL (e.g. https://vault.domain.com:8200)"
}

variable "vault_token" {
  description = "Vault token that will be used by Terraform to authenticate"
}