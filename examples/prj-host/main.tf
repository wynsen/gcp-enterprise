provider "google" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version     = "2.7.0"
}

# Host Project Configuration
module "prj_host" {
  source = "github.com/wynsen/gcp-enterprise//modules/prj-host?ref=v0.0.3"

  company_id         = "org"
  asset_id           = "shared"
  component_id       = "net"
  environment_id     = ""
  instance_id        = ""
  org_id             = ""
  folder_id          = "${var.folder_id}"
  billing_account_id = "${var.billing_account_id}"
  project_id_suffix  = false
}