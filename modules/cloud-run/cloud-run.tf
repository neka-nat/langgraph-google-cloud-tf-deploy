variable "gcp_project_id" {}
variable "service_name" {}
variable "primary_region" {}
variable "app_sa_email" {}
variable "serverless_connector_id" {}
variable "container_image_url" {}
variable "redis_host" {}
variable "cloud_sql_instance_name" {}
variable "cloud_sql_db_name" {}
variable "google_secret_manager_secret_version" {}
variable "required_apis" {}

resource "google_cloud_run_v2_service" "app" {
  name     = var.service_name
  location = var.primary_region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account                  = var.app_sa_email
    max_instance_request_concurrency = 10
    timeout                          = "90s"

    scaling {
      min_instance_count = 1
      max_instance_count = 4
    }

    # Redis など VPC 内リソースへのアクセス
    vpc_access {
      connector = var.serverless_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = ["${var.gcp_project_id}:${var.primary_region}:${var.cloud_sql_instance_name}"]
      }
    }

    containers {
      image = var.container_image_url

      ports {
        container_port = 8000
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "2Gi"
        }
      }

      env {
        name  = "POSTGRES_URI"
        value = "postgres://postgres:${var.google_secret_manager_secret_version.DATABASE_PASSWORD.secret_data}@/${var.cloud_sql_db_name}?host=/cloudsql/${var.gcp_project_id}:${var.primary_region}:${var.cloud_sql_instance_name}"
      }
      env {
        name  = "REDIS_URI"
        value = "redis://${var.redis_host}:6379"
      }

      env {
        name = "OPENAI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = "OPENAI_API_KEY"
            version = "latest"
          }
        }
      }

      env {
        name = "LANGSMITH_API_KEY"
        value_source {
          secret_key_ref {
            secret  = "LANGSMITH_API_KEY"
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [var.required_apis]
}

resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  count    = 1
  project  = var.gcp_project_id
  location = var.primary_region
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
