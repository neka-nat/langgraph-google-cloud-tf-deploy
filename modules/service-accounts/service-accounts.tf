variable "gcp_project_id" {}
variable "required_apis" {}
variable "app_sa_name" {}

resource "google_service_account" "app" {
  account_id   = var.app_sa_name
  display_name = "${var.app_sa_name} App Service Account"
  project      = var.gcp_project_id
  depends_on   = [var.required_apis]
}

# 必要最低限の IAM 権限
locals {
  roles_app = [
    "roles/cloudsql.client",
    "roles/vpcaccess.user",
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.reader",
  ]
}

resource "google_project_iam_member" "app_roles" {
  for_each = toset(local.roles_app)
  project  = var.gcp_project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.app.email}"
}

output "app_sa_email" { value = google_service_account.app.email }
