# Portainer Terraform Provider Reference

This document provides a comprehensive reference for the Portainer Terraform provider resources used in this workshop.

---

## Table of Contents
1. [Provider Configuration](#provider-configuration)
2. [portainer_stack Resource](#portainer_stack-resource)
3. [portainer_docker_image Resource](#portainer_docker_image-resource)
4. [portainer_deploy Resource](#portainer_deploy-resource)
5. [portainer_container_exec Resource](#portainer_container_exec-resource)
6. [Common Patterns](#common-patterns)

---

## Provider Configuration

The provider configuration tells Terraform how to connect to your Portainer instance.

```hcl
provider "portainer" {
  url                = var.portainer_url              # Portainer API URL
  api_key            = var.portainer_api_key          # API authentication token
  skip_ssl_verify    = var.portainer_skip_ssl_verify  # Skip SSL verification (for local dev)
}
```

**Variables:**
- `url`: The base URL of your Portainer instance (e.g., `https://localhost:9443`)
- `api_key`: Your Portainer API access token (starts with `ptr_`)
- `skip_ssl_verify`: Set to `true` for self-signed certificates in development

---

## portainer_stack Resource

Creates and manages a Docker Compose stack in Portainer.

### Basic Structure
```hcl
resource "portainer_stack" "my_stack" {
  name            = "stack-name"
  deployment_type = 1
  method          = "string"
  endpoint_id     = 1

  stack_file_path = "${path.module}/docker-compose.yml"

  env {
    name  = "ENV_VAR_NAME"
    value = "env-value"
  }

  lifecycle {
    prevent_destroy = true
  }
}
```

### Required Arguments
| Argument | Type | Description |
|----------|------|-------------|
| `name` | string | Name of the stack in Portainer |
| `deployment_type` | number | Type of deployment (1 = Compose, 2 = Swarm, 3 = Kubernetes) |
| `method` | string | Deployment method: "string" (inline), "file" (from file path), or "repository" (from Git) |
| `endpoint_id` | number | ID of the Portainer endpoint (environment) where stack will be deployed |

### Optional Arguments
| Argument | Type | Description |
|----------|------|-------------|
| `stack_file_path` | string | Path to the Docker Compose file (use with method = "file") |
| `stack_file` | string | Inline Docker Compose content as string (use with method = "string") |
| `env` | block | Environment variables to pass to the stack (can have multiple) |
| `lifecycle` | block | Terraform lifecycle rules (e.g., prevent_destroy) |

### Environment Variables Block
```hcl
env {
  name  = "VARIABLE_NAME"    # Environment variable name
  value = "variable_value"   # Environment variable value
}
```

You can have multiple `env` blocks for different variables.

### Lifecycle Block
```hcl
lifecycle {
  prevent_destroy = true  # Prevents accidental deletion of the stack
}
```

**When to use:** Add this to critical production resources to prevent accidental destruction.

### Special Variables
- `${path.module}`: Returns the filesystem path of the module where the expression is placed

---

## portainer_docker_image Resource

Pulls a Docker image to the endpoint, ensuring it's available before deployment.

### Basic Structure
```hcl
resource "portainer_docker_image" "my_image" {
  endpoint_id = 1
  image       = "nginx:latest"
}
```

### Required Arguments
| Argument | Type | Description |
|----------|------|-------------|
| `endpoint_id` | number | ID of the Portainer endpoint where the image should be pulled |
| `image` | string | Full image name with tag (e.g., "nginx:latest", "postgres:15") |

### What It Does
1. Connects to the specified Portainer endpoint
2. Pulls the specified Docker image from Docker Hub (or your configured registry)
3. Makes the image available for containers and services

**Why use it:** Ensures the image is available before trying to create containers, avoiding deployment failures.

---

## portainer_deploy Resource

Deploys or updates a service within a stack, typically used for rolling updates.

### Basic Structure
```hcl
resource "portainer_deploy" "my_deploy" {
  depends_on = [
    portainer_docker_image.my_image,
    portainer_stack.my_stack
  ]

  endpoint_id     = 1
  stack_name      = "stack-name"
  services_list   = "service-name"
  revision        = "v1.0.0"
  update_revision = true
  stack_env_var   = "VERSION"
  force_update    = true
  wait            = 10
}
```

### Required Arguments
| Argument | Type | Description |
|----------|------|-------------|
| `endpoint_id` | number | ID of the Portainer endpoint |
| `stack_name` | string | Name of the stack containing the service |
| `services_list` | string | Name of the service to deploy/update |

### Optional Arguments
| Argument | Type | Description |
|----------|------|-------------|
| `revision` | string | Version or revision identifier for the deployment |
| `update_revision` | bool | Whether to update the revision (triggers redeployment) |
| `stack_env_var` | string | Name of the environment variable to update with revision |
| `force_update` | bool | Force update even if nothing changed |
| `wait` | number | Seconds to wait for deployment to complete |
| `depends_on` | list | List of resources that must be created first |

### The depends_on Meta-Argument
```hcl
depends_on = [
  portainer_docker_image.pull,
  portainer_stack.my_stack
]
```

**What it does:** Defines explicit dependencies between resources. Terraform will create the listed resources before creating this one.

**When to use:** When implicit dependencies aren't detected automatically (e.g., when a deployment needs an image pulled first).

### Deployment Flow
1. Waits for all `depends_on` resources to be created
2. Connects to the specified stack and service
3. Updates the environment variable (if `stack_env_var` specified) with the `revision` value
4. Triggers a service update/redeploy
5. Waits for the specified duration for the deployment to complete

---

## portainer_container_exec Resource

Executes a command inside a running container.

### Basic Structure
```hcl
resource "portainer_container_exec" "my_exec" {
  depends_on = [portainer_deploy.my_deploy]

  endpoint_id  = 1
  service_name = "service-name"
  command      = "echo 'Hello World'"
  user         = "root"
}
```

### Required Arguments
| Argument | Type | Description |
|----------|------|-------------|
| `endpoint_id` | number | ID of the Portainer endpoint |
| `service_name` | string | Name of the service/container to execute command in |
| `command` | string | Command to execute inside the container |

### Optional Arguments
| Argument | Type | Description |
|----------|------|-------------|
| `user` | string | User to run the command as (default: container's default user) |
| `depends_on` | list | Resources that must exist before executing |

### Common Use Cases
- Initializing databases: `sqlite3 /data/db.sqlite 'CREATE TABLE...'`
- Reloading configurations: `nginx -s reload`
- Running migrations: `python manage.py migrate`
- Setting up initial data: `mysql -u root -p < /init.sql`

### Important Notes
- The command runs **after** the container is created and running
- Use `depends_on` to ensure the container is ready
- The command runs only during Terraform apply, not on every plan
- Failed commands will cause the Terraform apply to fail

---

## Common Patterns

### Pattern 1: Basic Stack Deployment
```hcl
# 1. Pull the image
resource "portainer_docker_image" "app_image" {
  endpoint_id = var.endpoint_id
  image       = "myapp:latest"
}

# 2. Create the stack
resource "portainer_stack" "app" {
  name            = "my-app"
  deployment_type = 1
  method          = "file"
  endpoint_id     = var.endpoint_id
  stack_file_path = "${path.module}/docker-compose.yml"
}
```

### Pattern 2: Stack with Version Updates
```hcl
# 1. Pull image
resource "portainer_docker_image" "app_image" {
  endpoint_id = var.endpoint_id
  image       = var.app_image
}

# 2. Create stack with version env var
resource "portainer_stack" "app" {
  name            = "my-app"
  deployment_type = 1
  method          = "file"
  endpoint_id     = var.endpoint_id
  stack_file_path = "${path.module}/docker-compose.yml"

  env {
    name  = "APP_VERSION"
    value = var.app_version
  }
}

# 3. Deploy/update with new version
resource "portainer_deploy" "app_deploy" {
  depends_on = [
    portainer_docker_image.app_image,
    portainer_stack.app
  ]

  endpoint_id     = var.endpoint_id
  stack_name      = "my-app"
  services_list   = "app-service"
  revision        = var.app_version
  update_revision = true
  stack_env_var   = "APP_VERSION"
  force_update    = true
  wait            = 10
}
```

### Pattern 3: Stack with Post-Deployment Commands
```hcl
# 1-3: Same as Pattern 2

# 4. Execute initialization command
resource "portainer_container_exec" "init" {
  depends_on = [portainer_deploy.app_deploy]

  endpoint_id  = var.endpoint_id
  service_name = "app-service"
  command      = "/app/init.sh"
  user         = "root"
}
```

### Pattern 4: Protected Production Stack
```hcl
resource "portainer_stack" "production_app" {
  name            = "prod-app"
  deployment_type = 1
  method          = "file"
  endpoint_id     = var.endpoint_id
  stack_file_path = "${path.module}/docker-compose.yml"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}
```

---

## Variable Best Practices

### Organize Variables by Purpose
```hcl
# Connection variables
variable "endpoint_id" {
  description = "Portainer endpoint ID"
  type        = number
}

# Stack configuration
variable "stack_name" {
  description = "Name of the stack"
  type        = string
}

variable "deployment_type" {
  description = "Stack deployment type (1=Compose, 2=Swarm, 3=K8s)"
  type        = number
  default     = 1
}

# Application variables
variable "app_image" {
  description = "Docker image to deploy"
  type        = string
}

variable "app_version" {
  description = "Application version"
  type        = string
}
```

### Use Defaults for Common Values
```hcl
variable "deployment_type" {
  description = "Stack deployment type"
  type        = number
  default     = 1  # Compose
}

variable "method" {
  description = "Stack deployment method"
  type        = string
  default     = "file"
}
```

---

## Resource Dependencies

### Implicit Dependencies
Terraform automatically detects dependencies when you reference one resource in another:
```hcl
resource "portainer_stack" "app" {
  name = "my-app"
  # ... other config
}

resource "portainer_deploy" "deploy" {
  stack_name = portainer_stack.app.name  # Implicit dependency created here
  # ... other config
}
```

### Explicit Dependencies
Use `depends_on` when Terraform can't detect the dependency automatically:
```hcl
resource "portainer_deploy" "deploy" {
  depends_on = [
    portainer_docker_image.pull,
    portainer_stack.app
  ]
  # ... config
}
```

**When to use depends_on:**
- When resources need to exist before another, but aren't directly referenced
- When you need to ensure a specific creation order
- When deploying requires images to be pulled first

---

## Troubleshooting Tips

### Issue: Stack Already Exists
**Error:** "Stack already exists in Portainer"
**Solution:** Import the existing stack or remove it from Portainer first
```bash
terraform import module.nginx.portainer_stack.standalone_file <stack_id>
```

### Issue: Image Not Found
**Error:** "Image not found when deploying"
**Solution:** Ensure `portainer_docker_image` resource exists and is in `depends_on`

### Issue: Command Execution Fails
**Error:** "Container exec failed"
**Solution:**
- Check if the container is running
- Verify the command syntax
- Ensure `depends_on` includes deployment resource
- Check if the user has permissions

### Issue: Cannot Destroy Stack
**Error:** "Cannot destroy protected resource"
**Solution:** Remove or comment out the `prevent_destroy` lifecycle block

---

## Quick Reference Card

| Resource | Purpose | Key Arguments |
|----------|---------|---------------|
| `portainer_stack` | Create Docker Compose stack | name, endpoint_id, stack_file_path |
| `portainer_docker_image` | Pull Docker image | endpoint_id, image |
| `portainer_deploy` | Deploy/update service | stack_name, services_list, revision |
| `portainer_container_exec` | Run command in container | service_name, command |

**Resource Order:**
1. `portainer_docker_image` (pull image)
2. `portainer_stack` (create stack)
3. `portainer_deploy` (deploy service)
4. `portainer_container_exec` (run commands)

---

For more information, visit the [Portainer Terraform Provider Documentation](https://registry.terraform.io/providers/portainer/portainer/latest/docs).
