variable "instance_number" {
  description = "(Optional) Instance Number. Allowed values: 0-99"
  default     = ""
}

variable "region" {
  description = "The Region to interface with the Google API and deploy Resources"
  default     = "australia-southeast1"
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}

variable "ipv4_range_psa" {
  description = "Private Services Access IPv4 Range. (e.g. 10.0.240.0/20)"
}