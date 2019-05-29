variable "region" {
  description = "The Region to interface with the Google API and deploy Resources"
  default     = "australia-southeast1"
}

variable "credentials_file_path" {
  description = "Location of the credentials to use"
  default     = "~/.config/gcloud/terraform-admin.json"
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}

variable "ipv4_range_psa" {
  description = "(Optional) Private Services Access IPv4 Range. (e.g. 10.0.240.0/20)"
  default     = ""
}

variable "router_asn" {
  description = "BGP ASN to provide to the Cloud Router"
}

variable "private_dns_zone_name" {
  description = "Private DNS Zone Name associated with the Shared VPC Network. (e.g. internal.domain.com.)"
}

variable "private_dns_zone_name_reverse" {
  description = "Private DNS Zone Name associated with the Shared VPC Network. (e.g. 0.10.in-addr.arpa.)"
}