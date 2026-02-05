# Creating a docker compose/stack for SQLite database
resource "portainer_stack" "sqlite_stack" {
  name            = var.sqlite_stack_name
  deployment_type = var.stack_deployment_type
  method          = var.stack_method
  endpoint_id     = var.stack_endpoint_id

  stack_file_path = "${path.module}/sqlite.yml"

  env {
    name  = var.sqlite_env_name
    value = var.sqlite_env_value
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "portainer_docker_image" "sqlite_pull" {
  endpoint_id = var.stack_endpoint_id
  image       = var.sqlite_image
}

### Deploy new version of SQLite service
resource "portainer_deploy" "sqlite_deploy" {
  depends_on = [
    portainer_docker_image.sqlite_pull,
    portainer_stack.sqlite_stack
  ]

  endpoint_id     = var.stack_endpoint_id
  stack_name      = var.sqlite_stack_name
  services_list   = var.sqlite_service_name
  revision        = var.sqlite_env_new_version_value
  update_revision = true
  stack_env_var   = var.sqlite_env_name
  force_update    = true
  wait            = 10
}

### Exec command to initialize database
resource "portainer_container_exec" "sqlite_exec" {
  depends_on = [portainer_deploy.sqlite_deploy]

  endpoint_id  = var.stack_endpoint_id
  service_name = var.sqlite_service_name
  command      = "sqlite3 /data/workshop.db 'CREATE TABLE IF NOT EXISTS visitors (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);'"
  user         = "root"
}

### Check status of SQLite service
resource "portainer_check" "sqlite_check" {
  depends_on = [portainer_container_exec.sqlite_exec]

  endpoint_id         = var.stack_endpoint_id
  stack_name          = var.sqlite_stack_name
  services_list       = var.sqlite_service_name
  revision            = var.sqlite_env_new_version_value
  desired_state       = "running"
  max_retries         = 3
  wait                = 10
  wait_between_checks = 5
}
