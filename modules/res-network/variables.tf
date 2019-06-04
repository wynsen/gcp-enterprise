variable "instance_id" {
  description = "(Optional) Asset Instance ID"
  default     = ""
}

variable "host_project_id" {
  description = "Shared VPC Network Host Project ID"
}

variable "ipv4_range_psa" {
  description = "Private Services Access IPv4 Range. (e.g. 10.0.240.0/20)"
  default     = ""
}

variable "router" {
  description = "Create a Cloud Router"
  default     = false
}

variable "router_asn" {
  description = "BGP ASN to assign to the Cloud Router (Required if router = true)"
  default     = "0"
}

variable "nat" {
  description = "Create a Cloud NAT Gateway"
  default     = false
}