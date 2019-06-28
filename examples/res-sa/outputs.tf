output "editor_sa_email" {
  value = "${module.res_sa.editor_sa_email}"
}

output "editor_sa_private_key" {
  value = "${base64decode(module.res_sa.editor_sa_secret_data["private_key_data"])}"
}