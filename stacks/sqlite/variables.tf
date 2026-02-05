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

# SQLite Stack Variables
variable "sqlite_stack_name" {
  description = "Name of the SQLite stack"
  type        = string
}

variable "sqlite_env_name" {
  description = "Environment variable name for SQLite version"
  type        = string
}

variable "sqlite_env_value" {
  description = "SQLite Docker image version/tag"
  type        = string
}

variable "sqlite_env_new_version_value" {
  description = "Environment variable value for new version of SQLite service"
  type        = string
}

variable "sqlite_image" {
  description = "SQLite Docker image to pull"
  type        = string
}

variable "sqlite_service_name" {
  description = "Name of the SQLite service in docker-compose"
  type        = string
}