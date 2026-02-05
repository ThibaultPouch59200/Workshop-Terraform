module "nginx" {
  source = "./stacks/nginx"

  portainer_url                     = var.portainer_url
  portainer_api_key                 = var.portainer_api_key
  portainer_skip_ssl_verify         = var.portainer_skip_ssl_verify

  stack_deployment_type             = var.stack_deployment_type
  stack_method                      = var.stack_method
  stack_endpoint_id                 = var.stack_endpoint_id

  nginx_stack_name                  = var.nginx_stack_name
  nginx_stack_env_name              = var.nginx_stack_env_name
  nginx_env_value                   = var.nginx_env_value
  nginx_env_new_version_value       = var.nginx_env_new_version_value
  nginx_image                       = var.nginx_image
  nginx_service_name                = var.nginx_service_name
}

module "sqlite" {
  source = "./stacks/sqlite"

  portainer_url                     = var.portainer_url
  portainer_api_key                 = var.portainer_api_key
  portainer_skip_ssl_verify         = var.portainer_skip_ssl_verify

  stack_deployment_type             = var.stack_deployment_type
  stack_method                      = var.stack_method
  stack_endpoint_id                 = var.stack_endpoint_id

  sqlite_stack_name                  = var.sqlite_stack_name
  sqlite_env_name                    = var.sqlite_env_name
  sqlite_env_value                   = var.sqlite_env_value
  sqlite_env_new_version_value       = var.sqlite_env_new_version_value
  sqlite_image                       = var.sqlite_image
  sqlite_service_name                = var.sqlite_service_name
}
