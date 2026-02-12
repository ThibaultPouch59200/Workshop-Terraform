# Exercise 4: Full Infrastructure Management

**Objective:** Deploy and manage all components together, explore updates and modifications

---

## Deploy Complete Infrastructure

If you followed exercises 1-3, your infrastructure should already be running. If not, deploy everything:

```bash
terraform plan
terraform apply
```

This deploys all three modules: nginx, sqlite, and webapp.

---

## Verify Complete Deployment

### Check All Resources

```bash
# List all Terraform-managed resources
terraform state list

# View resources by module
terraform state list module.nginx
terraform state list module.sqlite
terraform state list module.webapp
```

### Check All Containers

```bash
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
```

You should see:
- `workshop-nginx` - Nginx reverse proxy
- `workshop-sqlite` - SQLite database
- `workshop-webapp` - Node.js application
- `portainer` - Portainer management interface

---

## Explore the Application

### 1. Web Interface

Visit **http://localhost** in your browser.

Try:
- Adding visitors
- Viewing statistics
- Watching auto-refresh

### 2. API Endpoints

```bash
# Health check
curl http://localhost/health

# Get all visitors
curl http://localhost/api/visitors

# Add a visitor
curl -X POST http://localhost/api/visitors \
  -H "Content-Type: application/json" \
  -d '{"name":"API Test User"}'

# Get statistics
curl http://localhost/api/stats
```

### 3. Direct Database Access

```bash
# View all visitors
docker exec workshop-sqlite sqlite3 /data/workshop.db \
  "SELECT * FROM visitors ORDER BY visit_time DESC;"

# Count visitors
docker exec workshop-sqlite sqlite3 /data/workshop.db \
  "SELECT COUNT(*) FROM visitors;"
```

---

## Modify Infrastructure

### Exercise: Update Configuration

**Task:** Modify the Nginx configuration to add custom headers.

**Steps:**

1. **Check current configuration:**
   ```bash
   docker exec workshop-nginx cat /etc/nginx/conf.d/default.conf
   ```

2. **Edit the compose file** to add headers in `stacks/nginx/nginx.yml`

3. **Apply changes:**
   ```bash
   terraform apply
   ```

4. **Restart nginx to pick up changes:**
   ```bash
   docker restart workshop-nginx
   ```

---

## Understand Module Dependencies

### Dependency Chain

```
sqlite ─────▶ webapp
               │
nginx ─────────┘
```

- Webapp depends on sqlite (needs database)
- Nginx doesn't explicitly depend on others, but needs webapp to be available

### View Dependency Graph

```bash
terraform graph | dot -Tpng > graph.png
```

(Requires `graphviz` installed)

---

## Explore Terraform State

### View Specific Resources

```bash
# View nginx stack details
terraform state show module.nginx.portainer_stack.standalone_file

# View webapp deployment details
terraform state show module.webapp.portainer_deploy.webapp_deploy
```

### Understanding State

The state file tracks:
- What resources exist
- Their current configuration
- Dependencies between resources
- Metadata about creation/updates

**Never edit the state file manually!**

---

## Testing Resilience

### Test Container Recovery

```bash
# Stop webapp
docker stop workshop-webapp

# Wait a few seconds
sleep 5

# Terraform doesn't auto-restart it, but Docker restart policy does
docker ps | grep webapp
```

### Test Nginx Proxy

```bash
# Stop webapp
docker stop workshop-webapp

# Try accessing through nginx
curl http://localhost/health
# Should fail or timeout

# Start webapp
docker start workshop-webapp

# Wait for health check
sleep 10

# Try again
curl http://localhost/health
# Should succeed!
```

---

## ✅ Exercise Complete!

You've explored:
- ✅ Complete infrastructure deployment
- ✅ Inter-module dependencies
- ✅ State management
- ✅ Configuration updates
- ✅ Container resilience

**Key Concepts Learned:**
- Module orchestration
- Terraform state management
- Infrastructure updates and modifications
- Service dependencies and recovery

**Next:** [Exercise 5: Cleanup and Destroy →](5-cleanup.md)
