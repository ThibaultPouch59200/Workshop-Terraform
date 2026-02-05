variable "portainer_url" {
  description = "Default Portainer URL"
  type        = string
}

variable "portainer_api_key" {
  description = "Default Portainer Admin API Key"
  type        = string
  sensitive   = true
}

variable "portainer_skip_ssl_verify" {
  description = "Set to true to skip TLS certificate verification (useful for self-signed certs)"
  type        = bool
}

# Base Stack Variables
variable "stack_deployment_type" {
  description = "Deployment type: standalone, swarm, or kubernetes"
  type        = string
}

variable "stack_method" {
  description = "Creation method: string, file, repository, or url"
  type        = string
}

variable "stack_endpoint_id" {
  description = "Portainer environment/endpoint ID"
  type        = number
}

# Ngix Stack Variables
variable "nginx_stack_name" {
  description = "Name of the stack"
  type        = string
}

variable "nginx_stack_env_name" {
  description = "Environment variable name"
  type        = string
}

variable "nginx_env_value" {
  description = "Environment variable value"
  type        = string
}

variable "nginx_env_new_version_value" {
  description = "Environment variable value for new version fo service for deployment"
  type        = string
}

variable "nginx_image" {
  type    = string
}

variable "nginx_service_name" {
  type    = string
}
