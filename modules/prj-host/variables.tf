variable "client_code" {
  description = "Client Code"
}

variable "client_tribe" {
  description = "Client Tribe"
}

variable "client_squad" {
  description = "Client Squad"
}

variable "client_project" {
  description = "Client Project"
}

variable "client_environment" {
  description = "(Optional) Client Environment"
  default     = ""
}

variable "client_instance_number" {
  description = "(Optional) Client Instance Number. Allowed values: 0-999"
  default     = ""
}

variable "org_id" {
  description = "The ID of the Google Cloud Organization (only org_id or folder_id to be provided)"
  default = ""
}

variable "folder_id" {
  description = "The ID of the Google Cloud Organization Folder (only org_id or folder_id to be provided)"
  default = ""
}

variable "billing_account_id" {
  description = "The ID of the associated billing account"
}

variable "project_id_suffix" {
  description = "(Optional) Append a random 6 hexadecimal suffix to the Project Name for the Project ID (Default: true)"
  default = "true"
}