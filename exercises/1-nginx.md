# Exercise 1: Deploy Nginx Web Server

**Objective:** Build your first Terraform resource file from scratch to deploy Nginx using Portainer

📚 **Reference:** Keep `PORTAINER_PROVIDER_REFERENCE.md` open for detailed resource documentation.

---

## Understanding the Goal

**What we're building:**
- A complete Nginx web server stack managed by Terraform
- Using 4 different Portainer provider resources that work together

**The 4 resources:**
1. `portainer_docker_image` - Pulls the Nginx image
2. `portainer_stack` - Creates the stack from a Docker Compose file
3. `portainer_deploy` - Deploys and updates the service
4. `portainer_container_exec` - Configures Nginx (already embedded in compose file)

---

## Step 1: Create the File

```bash
touch stacks/nginx/nginx.tf
```

Open it in your editor and prepare to build it step by step.

---

## Step 2: Pull the Docker Image

**Your task:** Create a `portainer_docker_image` resource.

**Required arguments:**
- `endpoint_id`: Use `var.stack_endpoint_id`
- `image`: Use `var.nginx_image`

<details>
<summary>💡 Solution</summary>

```hcl
# Pull the Nginx Docker image
resource "portainer_docker_image" "pull" {
  endpoint_id = var.stack_endpoint_id
  image       = var.nginx_image
}
```
</details>

---

## Step 3: Create the Stack

**Your task:** Create a `portainer_stack` resource.

**Required:**
- Point to `nginx.yml` using `"${path.module}/nginx.yml"`
- Add environment variable for VERSION
- Add lifecycle protection

<details>
<summary>💡 Solution</summary>

```hcl
# Create the Nginx stack
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
```
</details>

---

## Step 4: Deploy the Service

**Your task:** Create a `portainer_deploy` resource with proper dependencies.

**Important:** Must depend on both the image pull and stack creation!

<details>
<summary>💡 Solution</summary>

```hcl
# Deploy the Nginx service
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
```
</details>

---

## Step 5: Validate Configuration

```bash
terraform validate
```

If successful, you're ready to deploy!

---

## Step 6: Deploy and Test

### Deploy

```bash
terraform plan -target=module.nginx
terraform apply -target=module.nginx
```

### Verify

```bash
# Check container
docker ps | grep nginx

# Test Nginx (will show default page until webapp is deployed)
curl http://localhost
```

---

## ✅ Exercise Complete!

You've successfully:
- ✅ Created your first Terraform resource file
- ✅ Used the Portainer provider
- ✅ Deployed Nginx with proper dependencies
- ✅ Learned about `depends_on` and resource relationships

**Key Concepts Learned:**
- Resource dependencies with `depends_on`
- Variables with `var.*`
- Path helpers with `${path.module}`
- Lifecycle rules with `prevent_destroy`

**Next:** Continue to [Exercise 2: Deploy SQLite →](2-sqlite.md)
