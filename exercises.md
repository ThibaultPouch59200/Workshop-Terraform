## Workshop Exercises

### Exercise 1: Understanding Terraform Basics
**Duration: 15-20 minutes**

**Objective:** Get familiar with Terraform commands and workflow

1. **Review Provided Configuration Files:**
   - Open `provider.tf` and identify the Portainer provider block
   - Open `variables.tf` and understand variable declarations
   - Open `entrypoint.tf` and see how modules are called
   - Review `stacks/nginx/provider.tf` and `stacks/nginx/variables.tf`
   - Review `stacks/sqlite/provider.tf` and `stacks/sqlite/variables.tf`

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```
   This creates a `.terraform` directory and downloads the Portainer provider plugin.

3. **Questions to Consider:**
   - What is a provider in Terraform?
   - What do variables do and how are they passed to modules?
   - How does Terraform track state?
   - What is the purpose of modules in Terraform?

---

### Exercise 2: Configure Local Portainer Connection
**Duration: 10-15 minutes**

**Objective:** Set up authenticated connection to your local Portainer instance

1. **Ensure Portainer is Running:**
   ```bash
   docker ps | grep portainer
   ```
   If not running, review README Step 2 to start Portainer.

2. **Get Your API Key:**
   - Access Portainer at `https://localhost:9443`
   - Go to User settings → Access tokens
   - Copy your API token (starts with `ptr_`)

3. **Create `terraform.tfvars` file:**
   ```hcl
   portainer_url              = "https://localhost:9443"
   portainer_api_key          = "ptr_YOUR_TOKEN_HERE"
   portainer_skip_ssl_verify  = true
   ```
   Replace `ptr_YOUR_TOKEN_HERE` with your actual API token.

   ⚠️ **Security Note:** Never commit this file to version control! It's already in `.gitignore`.

4. **Validate Configuration:**
   ```bash
   terraform validate
   ```

---

### Exercise 3: Create Nginx Stack Configuration
**Duration: 25-35 minutes**

**Objective:** Create your first Terraform resource file to deploy Nginx using Portainer

1. **Create `stacks/nginx/nginx.tf` file:**

   This file will define three resources:
   - A Portainer stack (from the nginx.yml compose file)
   - A Docker image pull operation
   - A deployment resource to update the service
   - An exec command to reload nginx

   ```hcl
   # Creating a docker compose/stack
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

   resource "portainer_docker_image" "pull" {
     endpoint_id = var.stack_endpoint_id
     image       = var.nginx_image
   }

   ### Deploy new version of service
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

   ### Exec some command in new version of service
   resource "portainer_container_exec" "exec" {
     depends_on = [portainer_deploy.deploy]

     endpoint_id  = var.stack_endpoint_id
     service_name = var.nginx_service_name
     command      = "nginx -s reload"
     user         = "root"
   }
   ```

2. **Understanding the Resources:**
   - `portainer_stack`: Creates a stack in Portainer from the nginx.yml file
   - `portainer_docker_image`: Pulls the nginx image
   - `portainer_deploy`: Deploys/updates the service
   - `portainer_container_exec`: Executes a command in the container
   - `depends_on`: Ensures resources are created in the right order

3. **Deploy Nginx Stack:**
   ```bash
   terraform plan
   terraform apply -target=module.nginx
   ```
   Review the plan and type `yes` to confirm.

4. **Verify Deployment:**
   - Check in Portainer UI (`https://localhost:9443`) → Stacks
   - Check running containers:
     ```bash
     docker ps | grep nginx
     ```
   - Test Nginx:
     ```bash
     curl http://localhost
     ```

5. **Questions to Consider:**
   - Why do we use `depends_on` in the deploy resource?
   - What does the `lifecycle` block with `prevent_destroy` do?
   - How does Terraform know which variables to use?

---

### Exercise 4: Create SQLite Stack Configuration
**Duration: 25-35 minutes**

**Objective:** Deploy a SQLite database with persistent storage

1. **Create `stacks/sqlite/sqlite.tf` file:**

   Similar structure to nginx.tf, but for SQLite database:

   ```hcl
   # Creating a docker compose/stack for SQLite database
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

   resource "portainer_docker_image" "sqlite_pull" {
     endpoint_id = var.stack_endpoint_id
     image       = var.sqlite_image
   }

   ### Deploy new version of SQLite service
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

   ### Exec command to initialize database
   resource "portainer_container_exec" "sqlite_exec" {
     depends_on = [portainer_deploy.sqlite_deploy]

     endpoint_id  = var.stack_endpoint_id
     service_name = var.sqlite_service_name
     command      = "sqlite3 /data/workshop.db 'CREATE TABLE IF NOT EXISTS visitors (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);'"
     user         = "root"
   }
   ```

2. **Understanding Database Initialization:**
   - The `portainer_container_exec` creates a database table
   - The SQLite data is persisted in a volume (defined in sqlite.yml)
   - The `depends_on` ensures the database is running before executing commands

3. **Deploy SQLite Stack:**
   ```bash
   terraform plan
   terraform apply -target=module.sqlite
   ```
   Review the plan and type `yes` to confirm.

4. **Verify Deployment:**
   - Check in Portainer UI → Stacks
   - Check running containers:
     ```bash
     docker ps | grep sqlite
     ```
   - Check volumes:
     ```bash
     docker volume ls | grep sqlite
     ```

5. **Challenge:**
   - Connect to the SQLite container and verify the table was created
   - Insert a test record into the visitors table

---

### Exercise 5: Complete Infrastructure Deployment
**Duration: 10-15 minutes**

**Objective:** Deploy all components together and understand the full infrastructure

1. **Deploy Everything:**
   ```bash
   terraform plan
   terraform apply
   ```
   - Review the complete execution plan
   - Understand how modules work together
   - Type `yes` to confirm

2. **Verify All Services:**
   ```bash
   # List all running containers
   docker ps

   # Check Terraform state
   terraform state list

   # View specific module resources
   terraform state list module.nginx
   terraform state list module.sqlite
   ```

3. **Test the Infrastructure:**
   - Open Portainer UI: `https://localhost:9443`
   - Navigate to Stacks and verify both stacks are running
   - Check container logs in Portainer
   - Test Nginx endpoint:
     ```bash
     curl http://localhost
     ```

4. **Explore Terraform State:**
   ```bash
   terraform state show module.nginx.portainer_stack.standalone_file
   terraform state show module.sqlite.portainer_stack.sqlite_stack
   ```

5. **Questions to Consider:**
   - How does the entrypoint.tf connect to the individual stack configurations?
   - What happens if one module fails during apply?
   - How are variables passed from root to modules?

---

### Exercise 6: Modify and Update Infrastructure
**Duration: 15-20 minutes**

**Objective:** Learn how to safely modify and update existing infrastructure

1. **Modify Nginx Configuration:**
   - Edit `stacks/nginx/nginx.conf` to change a setting
   - Run `terraform plan` to see what will change
   - Run `terraform apply` to update

2. **Update Environment Variables:**
   - In your `terraform.tfvars`, modify the nginx version
   - Apply the changes and observe the update process

3. **View Changes in Portainer:**
   - Check Portainer UI to see the updated stack
   - Review container details and environment variables

4. **Challenge:**
   - Add a new environment variable to the nginx stack
   - Update the nginx.tf file to include it
   - Apply and verify the change

---

### Exercise 7: Cleanup and Destroy
**Duration: 10-15 minutes**

**Objective:** Learn how to safely remove infrastructure

1. **Review What Will Be Destroyed:**
   ```bash
   terraform plan -destroy
   ```
   This shows what Terraform will remove.

2. **Destroy Resources:**
   ```bash
   terraform destroy
   ```
   Type `yes` to confirm.

   **Note:** Resources with `prevent_destroy = true` in their lifecycle block will cause an error. This is a safety feature!

3. **Remove Lifecycle Protection (if needed):**
   - Comment out or remove the `lifecycle { prevent_destroy = true }` blocks
   - Run `terraform destroy` again

4. **Verify Cleanup:**
   ```bash
   # Check containers (should be gone)
   docker ps -a | grep -E "nginx|sqlite"

   # Check Terraform state (should be empty)
   terraform state list

   # Check Portainer UI (stacks should be removed)
   ```

5. **Questions:**
   - What happens to volumes during destroy?
   - Why use `prevent_destroy` in production?
   - How would you preserve certain resources during cleanup?

6. **Clean Up Portainer (Optional):**
   ```bash
   # Stop and remove Portainer container
   docker stop portainer
   docker rm portainer

   # Remove Portainer volume (WARNING: deletes all Portainer data)
   docker volume rm portainer_data
   ```

---

## 🎯 Workshop Completion

Congratulations! You've completed the Terraform workshop. You now know how to:

✅ Set up a local Portainer instance for Docker management
✅ Configure Terraform with the Portainer provider
✅ Create Terraform resource configurations for containerized applications
✅ Deploy and manage Docker stacks using Infrastructure as Code
✅ Use Terraform modules for organized infrastructure
✅ Update and modify infrastructure safely
✅ Destroy infrastructure and clean up resources

### Next Steps:
- Explore adding more stacks (web apps, databases, monitoring tools)
- Learn about Terraform remote state management
- Practice with different providers (AWS, Azure, GCP)
- Implement CI/CD pipelines with Terraform
- Study Terraform best practices and advanced patterns

**Happy learning! 🚀**