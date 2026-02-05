## 📝 Workshop Exercises

### Exercise 1: Understanding Terraform Basics
**Duration: 15-20 minutes**

**Objective:** Get familiar with Terraform commands and workflow

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```
   This creates a `.terraform` directory and downloads necessary provider plugins.

2. **Review Configuration Files:**
   - Open `main.tf` and identify the provider block
   - Open `variables.tf` and understand variable declarations
   - Open `outputs.tf` and see what data will be returned

3. **Questions to Consider:**
   - What is a provider in Terraform?
   - What do variables and outputs do?
   - How does Terraform track state?

---

### Exercise 2: Configuring Portainer Connection
**Duration: 20-30 minutes**

**Objective:** Set up authenticated connection to your Portainer instance

1. **Create `terraform.tfvars` file:**
   ```hcl
   portainer_url       = "https://your-portainer-ip:9443"
   portainer_username  = "admin"
   portainer_password  = "your-password"
   portainer_env_id    = "1"  # Usually "1" for local environment
   ```
   ⚠️ **Security Note:** Never commit this file to version control. Add to `.gitignore`!

2. **Initialize Docker Provider:**
   ```bash
   terraform init
   ```

3. **Validate Configuration:**
   ```bash
   terraform validate
   ```

4. **Preview What Will Be Created:**
   ```bash
   terraform plan
   ```

---

### Exercise 3: Deploy Nginx Stack
**Duration: 15-20 minutes**

**Objective:** Deploy your first containerized service using Terraform

1. **Review `nginx/composition.tf`**
   - Understand the Nginx container configuration
   - Note environment variables and port mappings

2. **Deploy Nginx:**
   ```bash
   terraform apply -target=docker_container.nginx
   ```
   - Review the plan and type `yes` to confirm

3. **Verify Deployment:**
   ```bash
   # Check in Portainer UI or use Docker CLI
   docker ps | grep nginx
   curl http://localhost
   ```

4. **Challenge:** Modify the Nginx configuration to serve on port 8080 instead of 80

---

### Exercise 4: Deploy Web Application
**Duration: 20-30 minutes**

**Objective:** Deploy the web application container and understand dependencies

1. **Review `webapp/composition.tf`**
   - Understand the Web App container configuration
   - Note networking setup and environment variables

2. **Deploy Web Application:**
   ```bash
   terraform apply -target=docker_image.webapp
   terraform apply -target=docker_container.webapp
   ```

3. **Configure Networking:**
   - Ensure the Web App can communicate with Nginx
   - Verify network settings in configuration

4. **Test Application:**
   ```bash
   curl http://localhost:3000
   ```

5. **Challenge:** Add health check probes to your web application container

---

### Exercise 5: Deploy SQLite Database
**Duration: 15-20 minutes**

**Objective:** Set up persistent data storage and container networking

1. **Review `database/composition.tf`**
   - Understand volume configuration for data persistence
   - Review database initialization settings

2. **Create Docker Volume (if needed):**
   - Terraform will create volumes as defined in configuration
   - Understand why persistent volumes matter for databases

3. **Deploy Database:**
   ```bash
   terraform apply -target=docker_volume.sqlite_data
   terraform apply -target=docker_container.sqlite
   ```

4. **Verify Data Persistence:**
   - Create test data in SQLite
   - Destroy and recreate the container
   - Verify data persists

5. **Challenge:** Create a backup script for the database volume

---

### Exercise 6: Complete Infrastructure Deployment
**Duration: 10-15 minutes**

**Objective:** Deploy all components together and understand dependencies

1. **Deploy Everything:**
   ```bash
   terraform apply
   ```
   - Review the complete plan
   - Understand the resource dependency graph
   - Type `yes` to confirm

2. **Verify All Services:**
   ```bash
   terraform output
   docker ps
   ```

3. **Test End-to-End:**
   - Access web app through Nginx reverse proxy
   - Verify database connectivity
   - Check all logs

4. **Explore Terraform State:**
   ```bash
   terraform state list
   terraform state show docker_container.webapp
   ```

---

### Exercise 7: Cleanup and Destroy
**Duration: 10 minutes**

**Objective:** Learn how to safely remove infrastructure

1. **Destroy Resources in Reverse Order:**
   ```bash
   terraform destroy
   ```

2. **Verify Cleanup:**
   ```bash
   docker ps
   terraform state list  # Should be empty
   ```

3. **Questions:**
   - What happens to volumes during destroy?
   - How do you preserve certain resources during cleanup?