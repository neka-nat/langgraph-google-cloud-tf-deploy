variable "network_name" {}
variable "vpc_subnet_cidr" {}
variable "primary_region" {}
variable "vpc_connector_name" {}
variable "required_apis" {}


resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false
  depends_on              = [var.required_apis]
}

resource "google_compute_subnetwork" "serverless" {
  name          = "${var.network_name}-serverless"
  ip_cidr_range = var.vpc_subnet_cidr
  region        = var.primary_region
  network       = google_compute_network.main.id
  stack_type    = "IPV4_ONLY"
  purpose       = "PRIVATE"
}

resource "google_vpc_access_connector" "serverless" {
  name   = var.vpc_connector_name
  region = var.primary_region
  subnet {
    name = google_compute_subnetwork.serverless.name
  }
  min_instances = 2
  max_instances = 10
  depends_on    = [var.required_apis]
}

output "vpc_id" {
  value = google_compute_network.main.id
}

output "vpc_connector_id" {
  value = google_vpc_access_connector.serverless.id
}
