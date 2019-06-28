provider "vault" {
  address         = "${var.vault_url}"
  token           = "${var.vault_token}"
  skip_tls_verify = true
  version         = "2.0.0"
}

# Service Account Configuration
module "res_sa" {
#  source = "github.com/wynsen/gcp-enterprise//modules/res-sa?ref=v0.0.4"
  source = "../../modules/res-sa"

  project_id            = "${var.project_id}"
  credentials_file_path = "${var.credentials_file_path}"
}