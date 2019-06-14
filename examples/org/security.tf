# https://cloud.google.com/resource-manager/docs/organization-policy/creating-managing-policies
# https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints
# https://cloud.google.com/resource-manager/docs/organization-policy/understanding-constraints

# A separate Terraform deployment can be configured and executed in the context of an
# Organization Policy Administrator, however this requires Organization Policies applied to Folders
# to be configured in concert & two deployments executed.

# In lieu of the above, this file is to be configured with Code Owners security in GIT and managed by
# the Security Team. Folder IDs can therefore be dynamically passed to the Organization Policy Resources.

# Organization Policy Configuration
resource "google_organization_policy" "allowed_policy_member_domains" {
  org_id     = "${var.org_id}"
  constraint = "iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      values = ["${data.google_organization.org.directory_customer_id}"]
    }
  }
}

resource "google_organization_policy" "restrict_xpn_lien_removal" {
  org_id     = "${var.org_id}"
  constraint = "compute.restrictXpnProjectLienRemoval"

  boolean_policy {
    enforced = true
  }
}

resource "google_organization_policy" "skip_default_network_creation" {
  org_id     = "${var.org_id}"
  constraint = "compute.skipDefaultNetworkCreation"

  boolean_policy {
    enforced = true
  }
}

resource "google_organization_policy" "vm_external_ip_access" {
  org_id     = "${var.org_id}"
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    deny {
      all = true
    }
  }
}

/*
resource "google_folder_organization_policy" "vm_external_ip_access_override" {
  folder     = "${module.shared_servers.folder_id}"
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    allow {
      all = true
    }
  }
}

resource "google_organization_policy" "trusted_image_projects" {
  org_id     = "${var.org_id}"
  constraint = "compute.trustedImageProjects"

  list_policy {
    allow {
      values = [
        "projects/${var.images_project_id}",
        "projects/gce-uefi-images",
        "projects/debian-cloud"
      ]
    }
  }
}
*/

resource "google_folder_organization_policy" "trusted_image_projects_override" {
  folder     = "${google_folder.shared.id}"
  constraint = "compute.trustedImageProjects"

  list_policy {
    allow {
      all = true
    }
  }
}