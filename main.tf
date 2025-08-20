module "required-api" {
  source = "./modules/required-api"
}

module "service_accounts" {
  source         = "./modules/service-accounts"
  gcp_project_id = var.gcp_project_id
  required_apis  = module.required-api.required_apis
  app_sa_name    = var.service_account_name
}

module "artifact-registry" {
  source         = "./modules/artifact-registry"
  gcp_project_id = var.gcp_project_id
  primary_region = var.primary_region
  repository_id  = var.repository_id
  required_apis  = module.required-api.required_apis
}

module "secrets-manager" {
  source         = "./modules/secrets-manager"
  gcp_project_id = var.gcp_project_id
  secrets_file   = var.secrets_file
  accessors = [
    module.service_accounts.app_sa_email,
  ]
  required_apis = module.required-api.required_apis
}

module "cloud-sql" {
  source                               = "./modules/cloud-sql"
  gcp_project_id                       = var.gcp_project_id
  primary_region                       = var.primary_region
  cloud_sql_instance_name              = var.cloud_sql_instance_name
  db_name                              = var.cloud_sql_db_name
  required_apis                        = module.required-api.required_apis
  google_secret_manager_secret_version = module.secrets-manager.google_secret_manager_secret_version
}

module "network" {
  source             = "./modules/network"
  network_name       = var.network_name
  vpc_subnet_cidr    = var.vpc_subnet_cidr
  primary_region     = var.primary_region
  vpc_connector_name = var.vpc_connector_name
  required_apis      = module.required-api.required_apis
}

module "memorystore" {
  source           = "./modules/memorystore"
  primary_region   = var.primary_region
  memorystore_name = var.memorystore_name
  vpc_id           = module.network.vpc_id
  required_apis    = module.required-api.required_apis
}

module "cloud-run" {
  source                               = "./modules/cloud-run"
  gcp_project_id                       = var.gcp_project_id
  primary_region                       = var.primary_region
  service_name                         = var.cloud_run_name
  app_sa_email                         = module.service_accounts.app_sa_email
  serverless_connector_id              = module.network.vpc_connector_id
  container_image_url                  = module.artifact-registry.repository_url
  cloud_sql_instance_name              = module.cloud-sql.cloud_sql_instance_name
  cloud_sql_db_name                    = var.cloud_sql_db_name
  google_secret_manager_secret_version = module.secrets-manager.google_secret_manager_secret_version
  redis_host                           = module.memorystore.redis_host
  required_apis                        = module.required-api.required_apis
}
