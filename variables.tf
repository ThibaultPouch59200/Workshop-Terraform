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
  default     = "standalone"
}

variable "stack_method" {
  description = "Creation method: string, file, repository, or url"
  type        = string
  default     = "file"
}

variable "stack_endpoint_id" {
  description = "Portainer environment/endpoint ID"
  type        = number
  default     = 3
}

# Ngix Stack Variables
variable "nginx_stack_name" {
  description = "Name of the stack"
  type        = string
  default     = "nginx"
}

variable "nginx_stack_env_name" {
  description = "Environment variable name"
  type        = string
  default     = "VERSION"
}

variable "nginx_env_value" {
  description = "Environment variable value"
  type        = string
  default     = "1.28"
}

variable "nginx_env_new_version_value" {
  description = "Environment variable value for new version fo service for deployment"
  type        = string
  default     = "1.29"
}

variable "nginx_image" {
  type    = string
  default = "nginx:1.29"
}

variable "nginx_service_name" {
  type    = string
  default = "web"
}

# SQLite Stack Variables
variable "sqlite_stack_name" {
  description = "Name of the SQLite stack"
  type        = string
  default     = "sqlite"
}

variable "sqlite_env_name" {
  description = "Environment variable name for SQLite version"
  type        = string
  default     = "SQLITE_VERSION"
}

variable "sqlite_env_value" {
  description = "SQLite Docker image version/tag"
  type        = string
  default     = "latest"
}

variable "sqlite_env_new_version_value" {
  description = "Environment variable value for new version of SQLite service"
  type        = string
  default     = "latest"
}

variable "sqlite_image" {
  description = "SQLite Docker image to pull"
  type        = string
  default     = "nouchka/sqlite3:latest"
}

variable "sqlite_service_name" {
  description = "Name of the SQLite service in docker-compose"
  type        = string
  default     = "sqlite"
}

# Web Application Stack Variables
variable "webapp_stack_name" {
  description = "Name of the Web Application stack"
  type        = string
  default     = "webapp"
}

variable "webapp_env_name" {
  description = "Environment variable name for webapp version"
  type        = string
  default     = "WEBAPP_VERSION"
}

variable "webapp_env_value" {
  description = "Web Application Docker image version/tag"
  type        = string
  default     = "latest"
}

variable "webapp_env_new_version_value" {
  description = "Environment variable value for new version of webapp service"
  type        = string
  default     = "latest"
}

variable "webapp_image" {
  description = "Web Application Docker image to pull"
  type        = string
  default     = "workshop-webapp:latest"
}

variable "webapp_service_name" {
  description = "Name of the webapp service in docker-compose"
  type        = string
  default     = "webapp"
}