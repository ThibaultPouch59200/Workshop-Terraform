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
**Duration: 40-50 minutes**

**Objective:** Build your first Terraform resource file from scratch to deploy Nginx using Portainer. You'll learn how each resource works and why they're needed.

📚 **Reference:** Open `PORTAINER_PROVIDER_REFERENCE.md` for detailed resource documentation.

---

#### Part 1: Understanding the Goal (5 minutes)

Before writing code, let's understand what we're building:
- **What:** A complete Nginx web server stack managed by Terraform
- **How:** Using 4 different Portainer provider resources that work together
- **Why:** To deploy infrastructure as code, making deployments repeatable and version-controlled

**The 4 resources we'll create:**
1. `portainer_docker_image` - Pulls the Nginx image
2. `portainer_stack` - Creates the stack from a Docker Compose file
3. `portainer_deploy` - Deploys and updates the service
4. `portainer_container_exec` - Runs commands in the container

---

#### Part 2: Create the File Structure (2 minutes)

1. **Create the file:**
   ```bash
   touch stacks/nginx/nginx.tf
   ```

2. **Open it in your editor** and prepare to build it step by step.

---

#### Part 3: Pull the Docker Image (8-10 minutes)

**Why start here?** Before we can run a container, the image must exist on the system.

**Your task:** Create a `portainer_docker_image` resource that pulls the Nginx image.

**What you need to know:**
- Resource type: `portainer_docker_image`
- Resource name: You choose (e.g., "pull" or "nginx_image")
- Required arguments:
  - `endpoint_id`: Where to pull the image (use `var.stack_endpoint_id`)
  - `image`: Which image to pull (use `var.nginx_image`)

**Questions to answer:**
1. What does `var.stack_endpoint_id` represent?
2. Why use variables instead of hardcoding values?
3. Where are these variables defined?

**Try writing it yourself first!**

<details>
<summary>💡 Hint: Click to see the structure</summary>

```hcl
resource "portainer_docker_image" "pull" {
  endpoint_id = var.stack_endpoint_id
  image       = var.nginx_image
}
```
</details>

**Check your work:**
- Does your resource have both required arguments?
- Are you using the correct variable names from `variables.tf`?
- Did you give your resource a meaningful name?

---

#### Part 4: Create the Stack (12-15 minutes)

**What is a stack?** A Portainer stack is like a Docker Compose deployment. It defines how containers should run.

**Your task:** Create a `portainer_stack` resource that deploys the Nginx stack.

**Required information:**
- Resource type: `portainer_stack`
- Resource name: You choose (e.g., "standalone_file" or "nginx_stack")
- Required arguments:
  - `name`: Stack name in Portainer (use `var.nginx_stack_name`)
  - `deployment_type`: Type of deployment (use `var.stack_deployment_type`)
  - `method`: How to deploy (use `var.stack_method`)
  - `endpoint_id`: Where to deploy (use `var.stack_endpoint_id`)

**Additional requirements:**
- Set `stack_file_path` to point to the nginx.yml file in the same directory
  - **Hint:** Use `"${path.module}/nginx.yml"`
  - **What is `${path.module}`?** A Terraform variable that gives the current module's directory path

- Add an environment variable block:
  - The `env` block passes environment variables to your stack
  - Set `name` to `var.nginx_stack_env_name`
  - Set `value` to `var.nginx_env_value`

- Add lifecycle protection:
  - Add a `lifecycle` block with `prevent_destroy = true`
  - **Why?** Prevents accidental deletion of the stack

**Questions to answer:**
1. What file is `stack_file_path` pointing to?
2. Why might we want to pass environment variables to a stack?
3. What happens if you try to destroy this resource with `prevent_destroy = true`?

**Try writing it yourself!**

<details>
<summary>💡 Hint: Click to see the structure</summary>

```hcl
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

**Check your work:**
- Did you include all required arguments?
- Is the `stack_file_path` using `${path.module}`?
- Did you add the `env` block?
- Did you add the `lifecycle` block?

---

#### Part 5: Deploy the Service (12-15 minutes)

**What does this do?** The deploy resource triggers the actual deployment and handles updates.

**Your task:** Create a `portainer_deploy` resource.

**Critical concept - Dependencies!**
This resource must wait for:
1. The image to be pulled
2. The stack to be created

**How to specify dependencies:**
Use the `depends_on` argument with a list of resources:
```hcl
depends_on = [
  resource_type.resource_name,
  another_resource_type.another_name
]
```

**Required arguments:**
- `endpoint_id`: Where to deploy (use `var.stack_endpoint_id`)
- `stack_name`: Which stack to deploy (use `var.nginx_stack_name`)
- `services_list`: Which service to update (use `var.nginx_service_name`)

**Optional but recommended arguments:**
- `revision`: Version identifier (use `var.nginx_env_new_version_value`)
- `update_revision`: Set to `true` to trigger updates
- `stack_env_var`: Environment variable name to update (use `var.nginx_stack_env_name`)
- `force_update`: Set to `true` to force redeployment
- `wait`: Number of seconds to wait for deployment (use `10`)

**Questions to answer:**
1. Why do we need `depends_on` here?
2. What happens if the image isn't pulled before we try to deploy?
3. What does `update_revision = true` do?
4. Why wait 10 seconds?

**Try writing it yourself!**

<details>
<summary>💡 Hint: Click to see the structure</summary>

```hcl
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

**Check your work:**
- Did you include `depends_on` with both resources?
- Are you referencing the correct resource names from Parts 3 and 4?
- Did you include all the arguments?

---

#### Part 6: Execute Commands in Container (8-10 minutes)

**What does this do?** Runs a command inside the container after it's deployed.

**Your task:** Create a `portainer_container_exec` resource to reload Nginx configuration.

**Why reload Nginx?** After deployment, reloading ensures Nginx picks up any configuration changes without downtime.

**Required arguments:**
- `endpoint_id`: Where the container runs (use `var.stack_endpoint_id`)
- `service_name`: Which container to run command in (use `var.nginx_service_name`)
- `command`: The command to execute (use `"nginx -s reload"`)
- `user`: Which user runs the command (use `"root"`)

**Dependencies:**
This must wait for the deployment to complete!
- Add `depends_on` referencing your deploy resource from Part 5

**Questions to answer:**
1. What does `nginx -s reload` do?
2. Why does this need to depend on the deploy resource?
3. When does this command execute - every time or just once?
4. Why run as "root" user?

**Try writing it yourself!**

<details>
<summary>💡 Hint: Click to see the structure</summary>

```hcl
resource "portainer_container_exec" "exec" {
  depends_on = [portainer_deploy.deploy]

  endpoint_id  = var.stack_endpoint_id
  service_name = var.nginx_service_name
  command      = "nginx -s reload"
  user         = "root"
}
```
</details>

**Check your work:**
- Did you add the `depends_on` referencing your deploy resource?
- Is the command string correct?
- Did you include all required arguments?

---

#### Part 7: Review Your Complete File (3-5 minutes)

**Your `stacks/nginx/nginx.tf` should now have:**
1. ✅ A `portainer_docker_image` resource
2. ✅ A `portainer_stack` resource with env and lifecycle blocks
3. ✅ A `portainer_deploy` resource with proper dependencies
4. ✅ A `portainer_container_exec` resource

**Understanding the flow:**
```
Image Pull → Stack Creation → Service Deploy → Command Execution
     ↓              ↓               ↓                 ↓
   (Part 3)      (Part 4)        (Part 5)         (Part 6)
```

**Validate your configuration:**
```bash
terraform validate
```

If you see "Success!", your syntax is correct! 🎉

---

#### Part 8: Deploy and Test (5-7 minutes)

1. **See what Terraform will create:**
   ```bash
   terraform plan -target=module.nginx
   ```
   Review the output. You should see 4 resources to be created.

2. **Deploy the Nginx stack:**
   ```bash
   terraform apply -target=module.nginx
   ```
   Type `yes` to confirm.

3. **Verify deployment:**
   - Check Portainer UI: `https://localhost:9443` → Stacks
   - Check containers: `docker ps | grep nginx`
   - Test Nginx: `curl http://localhost`

**Success criteria:**
- ✅ All 4 resources created successfully
- ✅ Nginx container running
- ✅ HTTP request returns Nginx welcome page

---

#### Part 9: Understanding What You Built (5 minutes)

**Key Concepts Learned:**
1. **Resource Dependencies:** Using `depends_on` to control creation order
2. **Variables:** Using `var.*` to make configurations reusable
3. **Path Helpers:** Using `${path.module}` for file paths
4. **Lifecycle Rules:** Using `prevent_destroy` to protect resources
5. **Resource Relationships:** How resources reference each other

**Questions for Understanding:**
1. What happens if you remove `depends_on` from the deploy resource?
2. How would you deploy a different version of Nginx?
3. What would you need to change to deploy Apache instead?
4. How does Terraform track what resources it created?

---

**🎯 Exercise 3 Complete!** You've successfully built a complete Terraform configuration from scratch. Move on to Exercise 4 to apply these concepts to a database deployment.

---

### Exercise 4: Create SQLite Stack Configuration
**Duration: 40-50 minutes**

**Objective:** Apply what you learned in Exercise 3 to deploy a SQLite database with persistent storage. This time you'll work more independently!

📚 **Reference:** Keep `PORTAINER_PROVIDER_REFERENCE.md` open for resource documentation.

---

#### Part 1: Understand the Differences (5 minutes)

**Similarities to Exercise 3:**
- Same 4 resource types needed
- Same dependency pattern
- Same overall structure

**Key Differences:**
- Different image (SQLite instead of Nginx)
- Different variables (sqlite_* instead of nginx_*)
- Different initialization command (database creation instead of reload)
- Persistent storage for database data (defined in sqlite.yml)

**New Concepts:**
- **Persistent Volumes:** SQLite needs to store data that survives container restarts
- **Database Initialization:** Creating tables and schema on first deployment
- **SQL Commands:** Running SQL via command line

---

#### Part 2: Create the File (2 minutes)

```bash
touch stacks/sqlite/sqlite.tf
```

Open it in your editor and prepare to build it independently.

---

#### Part 3: Pull the SQLite Image (5-7 minutes)

**Your task:** Create a resource to pull the SQLite Docker image.

**Hints:**
- Resource type: `portainer_docker_image`
- Choose a meaningful resource name (e.g., "sqlite_pull")
- Use the correct SQLite variables from `stacks/sqlite/variables.tf`:
  - For endpoint: `var.stack_endpoint_id`
  - For image: `var.sqlite_image`

**Questions before you start:**
1. Check `stacks/sqlite/variables.tf` - what's the SQLite image variable called?
2. Is this resource structure different from the Nginx one?

**Try it yourself first!**

<details>
<summary>💡 Hint: Click to see the structure</summary>

```hcl
resource "portainer_docker_image" "sqlite_pull" {
  endpoint_id = var.stack_endpoint_id
  image       = var.sqlite_image
}
```
</details>

---

#### Part 4: Create the SQLite Stack (10-12 minutes)

**Your task:** Create the stack resource that defines how SQLite should run.

**Key information:**
- Resource type: `portainer_stack`
- Choose a meaningful name (e.g., "sqlite_stack")
- Point to the compose file: `"${path.module}/sqlite.yml"`
- Use SQLite-specific variables from `variables.tf`

**What you need to configure:**
1. Basic required arguments (name, deployment_type, method, endpoint_id)
2. The stack file path
3. An environment variable block for the SQLite version
4. Lifecycle protection

**Important:** Look at `stacks/sqlite/variables.tf` to find:
- `var.sqlite_stack_name` - for the stack name
- `var.sqlite_env_name` - for the env block's name
- `var.sqlite_env_value` - for the env block's value
- Other variables follow the same pattern as Nginx

**Questions to guide you:**
1. What does the `sqlite.yml` file contain? (Check it!)
2. Why do we need an environment variable for the database?
3. Should this stack have `prevent_destroy = true`? Why?

**Try building it independently!**

<details>
<summary>💡 Hint: Click to see the structure</summary>

```hcl
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

**Checkpoint:** Your stack resource should reference the SQLite compose file and environment variables.

---

#### Part 5: Deploy the Database Service (10-12 minutes)

**Your task:** Create the deploy resource to launch the SQLite service.

**Critical thinking:**
- What resources must exist before deployment can happen?
- What should be in your `depends_on` list?

**Configuration requirements:**
- Resource type: `portainer_deploy`
- Dependencies on image pull and stack creation
- All the deployment settings (endpoint, stack name, service name, etc.)
- Version management via revision and environment variable update

**Variable checklist from `variables.tf`:**
- `var.stack_endpoint_id` - endpoint
- `var.sqlite_stack_name` - stack name
- `var.sqlite_service_name` - service to deploy
- `var.sqlite_env_new_version_value` - revision
- `var.sqlite_env_name` - stack environment variable name

**Questions:**
1. How is this different from the Nginx deploy resource?
2. What will trigger a redeployment of the database?
3. Why force_update and wait?

**Build it yourself!**

<details>
<summary>💡 Hint: Click to see the structure</summary>

```hcl
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

**Pro tip:** Make sure your `depends_on` references match the resource names you created in Parts 3 and 4!

---

#### Part 6: Initialize the Database (12-15 minutes)

**Your task:** Create a resource that executes SQL to initialize the database.

**This is the most complex part!** You need to:
1. Run a command inside the SQLite container
2. Create a database file at `/data/workshop.db`
3. Create a `visitors` table with specific columns

**The SQL command you need to run:**
```sql
CREATE TABLE IF NOT EXISTS visitors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**How to run SQL in SQLite via command line:**
```bash
sqlite3 /data/workshop.db 'SQL_COMMAND_HERE'
```

**Your resource needs:**
- Resource type: `portainer_container_exec`
- Dependency on the deployment (must wait for container to be running)
- Endpoint ID and service name
- The complete sqlite3 command with SQL
- User: "root"

**Questions to solve:**
1. What's the full command string combining sqlite3 and the SQL?
2. Where should the database file be stored? (Hint: Check `sqlite.yml` for volume mounts)
3. What does `IF NOT EXISTS` do in the SQL?
4. Why does this need to depend on the deploy resource?

**Challenge yourself to build this!**

<details>
<summary>💡 Hint: Click to see the command structure</summary>

The command should be:
```hcl
command = "sqlite3 /data/workshop.db 'CREATE TABLE IF NOT EXISTS visitors (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);'"
```
</details>

<details>
<summary>💡 Hint: Click to see the complete resource</summary>

```hcl
resource "portainer_container_exec" "sqlite_exec" {
  depends_on = [portainer_deploy.sqlite_deploy]

  endpoint_id  = var.stack_endpoint_id
  service_name = var.sqlite_service_name
  command      = "sqlite3 /data/workshop.db 'CREATE TABLE IF NOT EXISTS visitors (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);'"
  user         = "root"
}
```
</details>

**Check your work:**
- Is the SQL command properly quoted?
- Did you include `depends_on`?
- Are you using the correct service name variable?

---

#### Part 7: Review and Validate (5 minutes)

**Your complete `stacks/sqlite/sqlite.tf` should have:**
1. ✅ `portainer_docker_image` resource (image pull)
2. ✅ `portainer_stack` resource (stack creation)
3. ✅ `portainer_deploy` resource (service deployment)
4. ✅ `portainer_container_exec` resource (database initialization)

**Validate your configuration:**
```bash
terraform validate
```

**If you get errors:**
- Check variable names against `stacks/sqlite/variables.tf`
- Verify resource references in `depends_on`
- Check for syntax errors (missing quotes, brackets, etc.)

---

#### Part 8: Deploy and Verify (8-10 minutes)

1. **Preview the deployment:**
   ```bash
   terraform plan -target=module.sqlite
   ```

2. **Deploy the SQLite stack:**
   ```bash
   terraform apply -target=module.sqlite
   ```

3. **Verify in multiple ways:**

   **Portainer UI:**
   - Visit `https://localhost:9443`
   - Check Stacks → Should see your SQLite stack
   - Check Containers → SQLite container should be running

   **Docker commands:**
   ```bash
   # Check container
   docker ps | grep sqlite

   # Check volume
   docker volume ls | grep sqlite
   ```

   **Connect to database:**
   ```bash
   # Get container name
   docker ps | grep sqlite

   # Connect to SQLite container
   docker exec -it <container-name> sh

   # Inside container, check database
   sqlite3 /data/workshop.db

   # In SQLite prompt, check table
   .tables
   .schema visitors
   .quit

   # Exit container
   exit
   ```

4. **Challenge: Insert test data!**
   ```bash
   docker exec -it <container-name> sqlite3 /data/workshop.db "INSERT INTO visitors (name) VALUES ('Your Name');"
   docker exec -it <container-name> sqlite3 /data/workshop.db "SELECT * FROM visitors;"
   ```

---

#### Part 9: Understanding Database Persistence (5 minutes)

**Experiment:** Test that your data persists!

1. **Restart the container:**
   ```bash
   docker restart <sqlite-container-name>
   ```

2. **Check if your data is still there:**
   ```bash
   docker exec -it <container-name> sqlite3 /data/workshop.db "SELECT * FROM visitors;"
   ```

**Questions:**
1. Why does the data persist after restart?
2. What would happen without a volume?
3. Where is the volume stored on your host machine?
4. What happens if you run `terraform destroy`?

**Hint:** Check the `sqlite.yml` file to understand volume configuration.

---

#### Part 10: Compare and Reflect (5 minutes)

**Side-by-side comparison:**

| Aspect | Nginx (Exercise 3) | SQLite (Exercise 4) |
|--------|-------------------|---------------------|
| **Image** | nginx:latest | nouchka/sqlite3:latest |
| **Purpose** | Web server | Database |
| **Command** | `nginx -s reload` | `sqlite3 /data/... 'CREATE TABLE...'` |
| **Persistence** | Not needed | Volume for /data |
| **Init Action** | Reload config | Create database table |

**Key Insights:**
1. **Same Pattern:** Both use the same 4-resource structure
2. **Different Purpose:** Web server vs. database
3. **Customization:** Variables make it reusable
4. **Dependencies:** `depends_on` ensures correct order

**Reflection Questions:**
1. Could you now create a PostgreSQL or MySQL stack?
2. What would change? What would stay the same?
3. How does understanding the pattern help you work faster?
4. Why is this better than manual Docker commands?

---

**🎯 Exercise 4 Complete!** You've now deployed both a web server and a database using Infrastructure as Code. You understand the Terraform resource pattern and can apply it to different services!

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