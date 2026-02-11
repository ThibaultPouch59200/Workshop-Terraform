# Exercise 5: Cleanup and Destroy

**Objective:** Learn how to safely tear down infrastructure and understand lifecycle management

---

## Understanding Destroy Operations

Terraform can remove all managed infrastructure with the `destroy` command. However, we've added safety measures with `prevent_destroy` lifecycle rules.

---

## Step 1: Review What Will Be Destroyed

```bash
terraform plan -destroy
```

This shows:
- What resources will be removed
- What order they'll be destroyed in
- Any lifecycle protection in place

**You'll likely see an error about `prevent_destroy`!** This is intentional - it protects critical resources.

---

## Step 2: Understanding Lifecycle Protection

Check any `.tf` file and find:

```hcl
lifecycle {
  prevent_destroy = true
}
```

**Purpose:** Prevents accidental deletion of:
- Production databases
- Critical services
- Resources with important data

---

## Step 3: Remove Lifecycle Protection (Optional)

If you want to destroy everything, you must first remove protection.

**Option A: Comment out lifecycle blocks**

In each stack's `.tf` file:

```hcl
# lifecycle {
#   prevent_destroy = true
# }
```

**Option B: Remove the lifecycle blocks entirely**

---

## Step 4: Destroy Infrastructure

```bash
terraform destroy -var-file="terraform.tfvars"
```

Type `yes` to confirm.

**This will:**
- Stop all containers
- Remove all stacks from Portainer
- Clean up Terraform state
- **Not** remove: volumes, networks, or local images

---

## Step 5: Verify Cleanup

### Check Containers

```bash
docker ps -a | grep -E "nginx|sqlite|webapp"
```

Should return nothing (containers removed).

### Check Terraform State

```bash
terraform state list
```

Should be empty.

### Check Portainer

Visit `https://localhost:9443` → Stacks

All workshop stacks should be gone.

---

## Step 6: Manual Cleanup (Optional)

Some resources persist after `terraform destroy`:

### Remove Docker Network

```bash
docker network rm workshop-network
```

### Remove Volumes (⚠️ DELETES ALL DATA)

```bash
# View volumes
docker volume ls | grep sqlite

# Remove SQLite volume (destroys all data!)
docker volume rm sqlite_sqlite-data

# Or remove all unused volumes
docker volume prune
```

### Remove Local Images

```bash
# Remove webapp image
docker rmi workshop-webapp:latest

# Remove other images
docker rmi nginx:1.28 nginx:1.29
docker rmi nouchka/sqlite3:latest
```

### Stop Portainer (Optional)

```bash
docker stop portainer
docker rm portainer
docker volume rm portainer_data
```

---

## Understanding What Persists

After `terraform destroy`:

| Resource | Status | Why? |
|----------|--------|------|
| Containers | ❌ Removed | Managed by Terraform |
| Stacks | ❌ Removed | Managed by Terraform |
| Networks | ✅ Persists | Created manually (not managed by Terraform) |
| Volumes | ✅ Persists | Data persistence (prevents accidental data loss) |
| Images | ✅ Persists | Reusable across deployments |

---

## Testing Full Reproducibility

**Challenge:** Can you recreate everything from scratch?

```bash
# 1. Clean up everything
terraform destroy -var-file="terraform.tfvars" -auto-approve

# 2. Recreate network
docker network create --driver bridge --subnet 172.20.0.0/16 workshop-network

# 3. Ensure webapp image exists
docker images | grep workshop-webapp

# 4. Deploy everything
terraform apply -var-file="terraform.tfvars" -auto-approve

# 5. Wait and test
sleep 30
curl http://localhost/health
```

**This is the power of Infrastructure as Code!** Everything is reproducible from configuration files.

---

## Best Practices for Production

### 1. Always Use `prevent_destroy` for Critical Resources

```hcl
lifecycle {
  prevent_destroy = true  # Protect databases, stateful services
}
```

### 2. Use Remote State

Store state in:
- Terraform Cloud
- AWS S3 + DynamoDB
- Azure Storage
- Google Cloud Storage

**Why?** Team collaboration and state locking.

### 3. Use Workspaces for Environments

```bash
terraform workspace new production
terraform workspace new staging
terraform workspace new development
```

### 4. Backup Before Destroy

```bash
# Backup volumes
docker run --rm -v sqlite_sqlite-data:/source -v $(pwd):/backup \
  alpine tar czf /backup/sqlite-backup.tar.gz -C /source .

# Then destroy
terraform destroy
```

---

## ✅ Workshop Complete!

Congratulations! You've completed the Terraform workshop and learned:

- ✅ Infrastructure as Code principles
- ✅ Terraform basics (init, plan, apply, destroy)
- ✅ Portainer provider usage
- ✅ Resource dependencies and lifecycle management
- ✅ Multi-tier application deployment
- ✅ Docker networking and volumes
- ✅ Safe infrastructure teardown

---

## Next Steps

Continue your learning with:

1. **Terraform Modules** - Create reusable module libraries
2. **Remote State** - Set up team collaboration
3. **CI/CD Integration** - Automate deployments
4. **Other Providers** - AWS, Azure, GCP
5. **Advanced Patterns** - Multi-environment setups, import existing resources

---

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Portainer Documentation](https://docs.portainer.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

**Thank you for completing the workshop! 🎉**
