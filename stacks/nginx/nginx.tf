# Creating a docker compose/stack as a stack mockup = simulating creating a stack manually in Portainer
resource "portainer_stack" "standalone_file" {
  name            = var.nginx_stack_name
  deployment_type = var.stack_deployment_type
  method          = var.stack_method
  endpoint_id     = var.stack_endpoint_id

  stack_file_path = "${path.module}/nginx.yml"

  env {
    name  = var.nginx_stack_env_name
    value = var.nginx_env_value
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "portainer_docker_image" "pull" {
  endpoint_id = var.stack_endpoint_id
  image       = var.nginx_image
}

### Deploy new version of service
resource "portainer_deploy" "deploy" {
  depends_on = [
    portainer_docker_image.pull,
    portainer_stack.standalone_file
  ]

  endpoint_id     = var.stack_endpoint_id
  stack_name      = var.nginx_stack_name
  services_list   = var.nginx_service_name
  revision        = var.nginx_env_new_version_value
  update_revision = true
  stack_env_var   = var.nginx_stack_env_name
  force_update    = true
  wait            = 10
}

### Exec some command in new version of service
resource "portainer_container_exec" "exec" {
  depends_on = [portainer_deploy.deploy]

  endpoint_id  = var.stack_endpoint_id
  service_name = var.nginx_service_name
  command      = "nginx -s reload"
  user         = "root"
}

### Check status of service with new version
resource "portainer_check" "check" {
  depends_on = [portainer_container_exec.exec]

  endpoint_id         = var.stack_endpoint_id
  stack_name          = var.nginx_stack_name
  services_list       = var.nginx_service_name
  revision            = var.nginx_env_new_version_value
  desired_state       = "running"
  max_retries         = 3
  wait                = 10
  wait_between_checks = 5
}