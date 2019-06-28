output "editor_sa_email" {
  value = "${vault_gcp_secret_roleset.editor.service_account_email}"
}

output "editor_sa_secret_data" {
  value = "${data.vault_generic_secret.editor.data}"
}

