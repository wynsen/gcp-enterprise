# Test Module to create a GCP Service Account with HashiCorp Vault and obtain a Key
# (e.g. for Terraform Delegated Service Accounts)
# Normally the GCP Secret Backend would be set up once in a different deployment
# And the Google Credentials would not be required

resource "vault_gcp_secret_backend" "gcp" {
  credentials               = "${file("${var.credentials_file_path}")}"
  default_lease_ttl_seconds = 1200
  max_lease_ttl_seconds     = 3600
}


resource "vault_gcp_secret_roleset" "editor" {
  backend      = "${vault_gcp_secret_backend.gcp.path}"
  roleset      = "project_editor"
  secret_type  = "service_account_key"
  project      = "${var.project_id}"
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"

    roles = [
      "roles/editor",
    ]
  }
}

data "vault_generic_secret" "editor" {
  path = "gcp/key/${vault_gcp_secret_roleset.editor.roleset}"
}