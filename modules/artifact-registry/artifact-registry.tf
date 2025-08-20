variable "gcp_project_id" {}
variable "primary_region" {}
variable "repository_id" {}
variable "required_apis" {}

locals {
  repo_id   = var.repository_id
  image_tag = "latest"
  image_uri = "${var.primary_region}-docker.pkg.dev/${var.gcp_project_id}/${local.repo_id}/${var.repository_id}:${local.image_tag}"
}

resource "google_artifact_registry_repository" "container_registry" {
  project       = var.gcp_project_id
  location      = var.primary_region
  repository_id = var.repository_id
  description   = "Docker repository for LangGraph based applications"
  format        = "DOCKER"

  depends_on = [var.required_apis]
}

resource "null_resource" "submit" {
  triggers = {
    src_hash = sha1(join("", [
      for f in fileset("${path.module}/../../sample_app", "**") :
      filemd5("${path.module}/../../sample_app/${f}")
    ]))
    image_uri = local.image_uri
  }

  provisioner "local-exec" {
    command = "gcloud builds submit --tag ${local.image_uri} ${path.module}/../../sample_app"
  }
}
output "repository_id" { value = google_artifact_registry_repository.container_registry.repository_id }
output "repository_url" {
  value = "${var.primary_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.container_registry.repository_id}/${google_artifact_registry_repository.container_registry.repository_id}:latest"
}
