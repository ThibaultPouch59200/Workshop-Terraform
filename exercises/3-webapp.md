# Exercise 3: Deploy Web Application

**Objective:** Complete your infrastructure by deploying a custom Node.js web application that connects to the SQLite database

📚 **Reference:** Keep `PORTAINER_PROVIDER_REFERENCE.md` open for resource documentation.

---

## Understanding the Web Application

**What is it?**
A Node.js/Express application that:
- Displays a visitor management interface
- Connects to the SQLite database
- Provides RESTful API endpoints
- Includes health check endpoint
- Auto-refreshes data every 10 seconds

**Architecture:**
```
Browser → Nginx (port 80) → Web App (port 3000) → SQLite Database
```

---

## Key Differences from Previous Exercises

### 1. Custom Docker Image

Unlike Nginx and SQLite which use public images, the webapp uses a **locally built image**:
- Image name: `workshop-webapp:latest`
- Already built in Exercise 0
- Not available on Docker Hub

### 2. No Image Pull Resource

Since the image is local, we **don't use** `portainer_docker_image` for pulling. Terraform will use the local image directly.

### 3. Special Deployment Settings

```hcl
force_update    = false  # Don't try to pull the image
update_revision = false  # Don't trigger updates on version changes
```

These settings prevent Terraform from trying to pull the image from a registry.

---

## Step 1: Verify Prerequisites

Before starting, ensure:

```bash
# 1. Webapp image exists
docker images | grep workshop-webapp

# 2. SQLite is running
docker ps | grep sqlite

# 3. Network exists
docker network ls | grep workshop
```

All three must be ready before deploying the webapp!

---

## Step 2: Create the File

```bash
touch stacks/webapp/webapp.tf
```

---

## Step 3: Create the Stack

**Your task:** Create the webapp stack resource.

**Special notes:**
- No image pull resource needed (using local image)
- Point to `webapp.yml` in same directory
- Environment variable: `WEBAPP_VERSION`

<details>
<summary>💡 Solution</summary>

```hcl
# Create the webapp stack
# Note: The Docker image must be built locally before running terraform
# Build command: docker build -t workshop-webapp:latest stacks/webapp/
resource "portainer_stack" "webapp_stack" {
  name            = var.webapp_stack_name
  deployment_type = var.stack_deployment_type
  method          = var.stack_method
  endpoint_id     = var.stack_endpoint_id

  stack_file_path = "${path.module}/webapp.yml"

  env {
    name  = var.webapp_env_name
    value = var.webapp_env_value
  }

  lifecycle {
    prevent_destroy = true
  }
}
```
</details>

---

## Step 4: Deploy the Service

**Your task:** Create the deploy resource with **special settings for local images**.

**Critical:** Set `force_update = false` and `update_revision = false`!

<details>
<summary>💡 Solution</summary>

```hcl
# Deploy the webapp service
# Note: force_update is disabled to prevent pulling the locally-built image
resource "portainer_deploy" "webapp_deploy" {
  depends_on = [
    portainer_stack.webapp_stack
  ]

  endpoint_id     = var.stack_endpoint_id
  stack_name      = var.webapp_stack_name
  services_list   = var.webapp_service_name
  revision        = var.webapp_env_new_version_value
  update_revision = false
  stack_env_var   = var.webapp_env_name
  force_update    = false
  wait            = 15
}

# Note: Webapp health check can be verified manually after deployment
# Check: curl http://localhost:3000/health
```
</details>

**Why these settings?**
- `force_update = false`: Don't try to pull the image from a registry
- `update_revision = false`: Don't trigger redeployment on version changes
- `wait = 15`: Give the webapp time to start and connect to the database

---

## Step 5: Validate and Deploy

```bash
terraform validate
terraform plan -target=module.webapp
terraform apply -target=module.webapp
```

---

## Step 6: Verify the Deployment

### Check Container Status

```bash
# Should see: webapp, sqlite, nginx all running
docker ps
```

### Test Direct Access (Port 3000)

```bash
# Health check
curl http://localhost:3000/health

# Should return: {"status":"healthy","timestamp":"...","database":"connected"}
```

### Test via Nginx Proxy (Port 80)

```bash
# Health check through proxy
curl http://localhost/health

# Access full application
curl http://localhost/
```

### Open in Browser

Visit **http://localhost** to see the full application!

You should see:
- Visitor management interface
- List of visitors from the database
- Ability to add new visitors
- Real-time statistics

---

## Step 7: Test Full Stack Integration

### Add a Visitor via API

```bash
curl -X POST http://localhost/api/visitors \
  -H "Content-Type: application/json" \
  -d '{"name":"Your Name from Workshop"}'
```

### View All Visitors

```bash
curl http://localhost/api/visitors
```

### Check in Database

```bash
docker exec workshop-sqlite sqlite3 /data/workshop.db \
  "SELECT * FROM visitors ORDER BY visit_time DESC LIMIT 5;"
```

You should see your new visitor in the database!

---

## Understanding the Complete Architecture

### Container Communication

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   Browser   │─────▶│    Nginx     │─────▶│   WebApp    │
│             │      │   (port 80)  │      │  (port 3000)│
└─────────────┘      └──────────────┘      └──────┬──────┘
                                                   │
                                                   │
                                            ┌──────▼──────┐
                                            │   SQLite    │
                                            │  (database) │
                                            └─────────────┘
```

### Network Configuration

All containers are on `workshop-network`:
- Nginx finds webapp at: `workshop-webapp:3000`
- Webapp finds database via shared volume: `/data/workshop.db`
- Nginx proxies external traffic from port 80 to webapp

### Data Flow

1. **User visits** `http://localhost`
2. **Nginx receives** request on port 80
3. **Nginx proxies** to `workshop-webapp:3000`
4. **Webapp queries** SQLite database
5. **Response** flows back through Nginx to user

---

## Troubleshooting

### Webapp Container Restarting?

```bash
# Check logs
docker logs workshop-webapp

# Common issues:
# - Database not accessible (check sqlite container)
# - Volume mount permissions
# - Port conflicts
```

### Can't Access on Port 80?

```bash
# Check nginx configuration
docker logs workshop-nginx

# Verify nginx is proxying correctly
docker exec workshop-nginx cat /etc/nginx/conf.d/default.conf
```

### Database Connection Errors?

```bash
# Verify volume exists
docker volume ls | grep sqlite

# Check database file
docker exec workshop-sqlite ls -la /data/
```

---

## ✅ Exercise Complete!

You've successfully:
- ✅ Deployed a custom web application
- ✅ Connected webapp to database
- ✅ Set up Nginx as reverse proxy
- ✅ Configured container networking
- ✅ Tested the complete stack

**Key Concepts Learned:**
- Working with locally built Docker images
- Container-to-container communication
- Reverse proxy configuration
- Full-stack application deployment
- API integration with database

**🎉 Your complete infrastructure is now running!**

---

## Next Steps

**[Exercise 4: Full Infrastructure Management →](4-full-infrastructure.md)**
Learn how to manage, update, and maintain your complete infrastructure.
