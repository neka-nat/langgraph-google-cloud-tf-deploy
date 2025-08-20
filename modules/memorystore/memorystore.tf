variable "primary_region" {}
variable "memorystore_name" {}
variable "vpc_id" {}
variable "required_apis" {}

resource "google_redis_instance" "redis" {
  name               = "${var.memorystore_name}-redis"
  tier               = "BASIC"
  memory_size_gb     = 1
  region             = var.primary_region
  redis_version      = "REDIS_7_0"
  authorized_network = var.vpc_id

  depends_on = [var.required_apis]
}

output "redis_host" {
  value = google_redis_instance.redis.host
}
