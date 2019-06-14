provider "google" {
  region = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version = "2.7.0"
}

# General Project (No Subnets) Configuration
module "prj_simple" {
  source = "github.com/wynsen/gcp-enterprise//modules/prj-simple?ref=v0.0.3"

  company_id         = "org"
  asset_id           = "shared"
  component_id       = "img"
  environment_id     = ""
  instance_id        = ""
  org_id             = ""
  folder_id          = "${var.folder_id}"
  billing_account_id = "${var.billing_account_id}"
  project_id_suffix  = false
  host_project_id    = "${var.host_project_id}"
}