# Example of a Compute Project deployment

provider "google" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version     = "2.7.0"
}

provider "google-beta" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version     = "2.7.0"
}

# General Compute Project Configuration
module "prj_compute" {
#  source = "github.com/wynsen/gcp-enterprise//modules/prj-compute?ref=v0.0.4"
  source = "../../modules/prj-compute"

  company_id               = "org"
  asset_id                 = "app1"
  component_id             = "vm"
  environment_id           = "dev"
  instance_id              = ""
  org_id                   = ""
  folder_id                = "${var.folder_id}"
  billing_account_id       = "${var.billing_account_id}"
  terraform_delegate_email = "${var.terraform_delegate_email}"
  editor_group_email       = "${var.editor_group_email}"
  host_project_id          = "${var.host_project_id}"
  shared_network_name      = "org-shared-net-int-vpc"
  ipv4_range_primary       = "10.0.1.0/24"
  subnet_flow_logs         = false
}