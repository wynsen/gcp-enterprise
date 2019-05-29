output "folder_id" {
  value = "${google_folder.folder.id}"
}

output "service_account_terraform" {
  value = "${google_service_account.terraform.email}"
}

output "gsuite_group_viewers" {
  value = "${gsuite_group.viewer.email}"
}

output "gsuite_group_editors" {
  value = "${gsuite_group.editor.email}"
}

output "gsuite_group_oslogin" {
  value = "${gsuite_group.oslogin.email}"
}