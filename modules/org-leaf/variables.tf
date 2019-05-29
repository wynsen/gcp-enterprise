variable "folder_name" {
  description = "Folder Name"
}

variable "parent_folder_name" {
  description = "Parent Folder Name"
}

variable "admin_project_id" {
  description = "Admin Project ID"
}

variable "images_project_id" {
  description = "(Optional) Images Project ID"
  default = ""
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}

variable "breakglass_enabled" {
  description = "Create a Break-Glass Group (default: false)"
  default = false
}