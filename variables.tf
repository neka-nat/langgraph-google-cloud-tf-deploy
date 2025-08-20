variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "repository_id" {
  description = "Repository ID"
  type        = string
}

variable "secrets_file" {
  description = "Secrets file"
  type        = string
}

variable "cloud_sql_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "cloud_sql_db_name" {
  description = "Database name"
  type        = string
}

variable "network_name" {
  description = "Network name"
  type        = string
}

variable "vpc_subnet_cidr" {
  description = "VPC subnet CIDR"
  type        = string
}

variable "vpc_connector_name" {
  description = "VPC connector name"
  type        = string
}

variable "memorystore_name" {
  description = "Memorystore name"
  type        = string
}

variable "service_account_name" {
  description = "App service account name"
  type        = string
}

variable "cloud_run_name" {
  description = "Service name"
  type        = string
}
