## Portainer connection variables
variable "portainer_url" {
  description = "Portainer API URL"
  type        = string
}

variable "portainer_api_key" {
  description = "Portainer API key for authentication"
  type        = string
  sensitive   = true
}

variable "portainer_skip_ssl_verify" {
  description = "Skip SSL verification (for self-signed certificates)"
  type        = bool
  default     = true
}

## Stack deployment variables
variable "stack_deployment_type" {
  description = "Deployment type: standalone, swarm, or kubernetes"
  type        = string
}

variable "stack_method" {
  description = "Stack deployment method (string, file, repository)"
  type        = string
  default     = "file"
}

variable "stack_endpoint_id" {
  description = "Portainer endpoint ID where the stack will be deployed"
  type        = number
}

## Webapp-specific variables
variable "webapp_stack_name" {
  description = "Name of the webapp stack in Portainer"
  type        = string
}

variable "webapp_env_name" {
  description = "Environment variable name for webapp version"
  type        = string
  default     = "VERSION"
}

variable "webapp_env_value" {
  description = "Initial version value for webapp"
  type        = string
  default     = "latest"
}

variable "webapp_env_new_version_value" {
  description = "New version value for webapp updates"
  type        = string
  default     = "v1.0.0"
}

variable "webapp_image" {
  description = "Docker image for the webapp"
  type        = string
  default     = "workshop-webapp:latest"
}

variable "webapp_service_name" {
  description = "Service name for the webapp container"
  type        = string
  default     = "workshop-webapp"
}
