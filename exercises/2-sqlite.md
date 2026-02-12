# Exercise 2: Deploy SQLite Database

**Objective:** Apply your knowledge to deploy a SQLite database with persistent storage and automatic initialization

📚 **Reference:** Keep `PORTAINER_PROVIDER_REFERENCE.md` open for resource documentation.

## Understanding SQLite Stack

**Key Differences from Nginx:**
- Persistent storage via Docker volumes
- Database initialization embedded in compose file
- Automatic table creation on first run

**What's Special:**
The `sqlite.yml` file contains embedded initialization scripts that:
- Create database tables automatically
- Add sample data
- Set up indexes and settings

All of this happens on container startup!

---

## Step 1: Create the File

```bash
touch stacks/sqlite/sqlite.tf
```

## Step 2: Pull the SQLite Image

**Your task:** Create a `portainer_docker_image` resource for SQLite.

Use:
- `var.stack_endpoint_id`
- `var.sqlite_image`

<details>
<summary>💡 Solution</summary>

```hcl
# Pull the SQLite Docker image
resource "portainer_docker_image" "sqlite_pull" {
  endpoint_id = var.stack_endpoint_id
  image       = var.sqlite_image
}
```
</details>

## Step 3: Create the Stack

**Your task:** Create the stack resource.

**Key points:**
- Point to `sqlite.yml` in same directory
- Add environment variable for SQLITE_VERSION
- Include lifecycle protection

<details>
<summary>💡 Solution</summary>

```hcl
# Create the SQLite stack
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
```
</details>

## Step 4: Deploy the Service

**Your task:** Create the deploy resource with dependencies.

<details>
<summary>💡 Solution</summary>

```hcl
# Deploy the SQLite service
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
```
</details>

**Note:** We removed the `portainer_container_exec` for database initialization because it's now embedded in the `sqlite.yml` file! Check the compose file to see how initialization is done on startup.

## Step 5: Validate and Deploy

```bash
terraform validate
terraform plan -target=module.sqlite
terraform apply -target=module.sqlite
```

## Step 6: Verify Database

### Check Container

```bash
docker ps | grep sqlite
```

### Verify Database Tables

```bash
# Connect to the database
docker exec workshop-sqlite sqlite3 /data/workshop.db ".tables"

# Check the schema
docker exec workshop-sqlite sqlite3 /data/workshop.db ".schema visitors"

# View sample data
docker exec workshop-sqlite sqlite3 /data/workshop.db "SELECT * FROM visitors;"
```

You should see:
- `visitors` table
- `app_settings` table
- Sample data (Alice, Bob, Charlie)

**All created automatically from the embedded initialization script!**

---

## ✅ Exercise Complete!

You've successfully:
- ✅ Deployed a database with persistent storage
- ✅ Used embedded initialization scripts
- ✅ Verified automatic database setup
- ✅ Tested data persistence across restarts

**Key Concepts Learned:**
- Docker volumes for data persistence
- Embedded startup scripts in Docker Compose
- Database initialization patterns
- Same 3-resource pattern as Nginx (pull, stack, deploy)

**Next:** Continue to [Exercise 3: Deploy Web Application →](3-webapp.md)
