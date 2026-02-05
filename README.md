# Terraform Workshop: Infrastructure as Code with Portainer

## 📚 Workshop Overview

Welcome to the **Terraform Workshop**! This hands-on learning experience will guide you through the fundamentals of Terraform by building a simple yet practical infrastructure. You'll learn how to use **Infrastructure as Code (IaC)** principles to deploy a containerized web application stack on a Portainer-hosted Docker environment.

By the end of this workshop, you'll understand how to:
- Write Terraform configurations to manage infrastructure
- Deploy multi-container applications using Terraform
- Manage Docker stacks and services through code
- Apply best practices for reproducible infrastructure

---

## 🎯 Learning Objectives

After completing this workshop, you should be able to:

1. **Understand Terraform basics**
   - Know what Infrastructure as Code (IaC) is and its benefits
   - Understand the Terraform workflow (init, plan, apply, destroy)
   - Work with Terraform configuration files (.tf files)

2. **Configure Docker providers**
   - Set up the Docker provider in Terraform
   - Authenticate with Portainer API
   - Manage Docker resources through Terraform

3. **Deploy a multi-tier application**
   - Define and deploy three Docker stacks:
     - **Nginx**: Reverse proxy and web server
     - **SQLite**: Lightweight database
     - **Web App**: Custom application
   - Configure networking between containers
   - Manage volumes and data persistence

4. **Apply infrastructure management best practices**
   - Use state files to track infrastructure
   - Create reusable modules and configurations
   - Manage variables and outputs
   - Handle sensitive data securely

---

## 🏗️ Architecture Overview

This workshop builds a simple three-tier web application architecture:

```
┌─────────────────────────────────────────────┐
│           Portainer Platform                │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────┐   ┌──────────────┐        │
│  │    Nginx     │   │   Web App    │        │
│  │  (Port 80)   │──→│  (Port 3000) │        │
│  └──────────────┘   └─────────┬────┘        │
│                               │             │
│                       ┌───────▼─────┐       │
│                       │   SQLite    │       │
│                       │  (Database) │       │
│                       └─────────────┘       │
│                                             │
└─────────────────────────────────────────────┘
```

### Components

| Component | Purpose | Port | Technology |
|-----------|---------|------|------------|
| **Nginx** | Reverse proxy & web server | 80 | Docker Container |
| **Web App** | Custom application | 3000 | Docker Container |
| **SQLite** | Lightweight relational database | - | Docker Container |

---

## 📋 Prerequisites

### System Requirements
- Portainer instance running and accessible
- Portainer admin/user credentials with API access enabled
- Access to Portainer's Docker API
- Basic understanding of Docker concepts (containers, images, networking)

### Software Requirements
- Terraform (version 1.0+) installed on your local machine
  - [Download Terraform](https://www.terraform.io/downloads.html)
- Docker CLI (optional, for manual verification)
- A text editor or IDE (VS Code recommended)

### Knowledge Requirements
- Familiarity with command line/terminal
- Basic understanding of Docker containers
- No Terraform experience needed - we'll learn together!

---

## 🚀 Getting Started

### Step 1: Install Terraform
**On macOS:**
```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**On Linux:**
```bash
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

Verify installation:
```bash
terraform version
```

### Step 2: Prepare Your Environment

1. **Gather Portainer Information:**
   - Portainer URL/IP address
   - Admin username and password (or API token)
   - Portainer environment ID

2. **Clone or Navigate to Workshop Repository:**
   ```bash
   cd Workshop-Terraform
   ```

3. **Review the Project Structure:**
   ```
   Workshop-Terraform/
   ├── README.md                    # This file
   ├── main.tf                      # Main Terraform configuration
   ├── variables.tf                 # Variable declarations
   ├── outputs.tf                   # Output definitions
   ├── docker_provider.tf           # Docker provider setup
   ├── nginx/                       # Nginx stack configuration
   │   └── composition.tf
   ├── webapp/                      # Web application stack configuration
   │   └── composition.tf
   └── database/                    # SQLite stack configuration
       └── composition.tf
   ```

---

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

---

## 🔑 Key Terraform Concepts

### State Files
- `terraform.tfstate`: Tracks current infrastructure state
- Keep this file safe and backed up
- Never manually edit this file
- Consider remote state for team environments

### Providers
- Terraform plugins that interact with APIs (Docker, AWS, Azure, etc.)
- Configured in `docker_provider.tf`
- Require authentication credentials

### Resources
- Infrastructure objects managed by Terraform (containers, volumes, networks)
- Defined with `resource` blocks
- Each resource has a unique type and name

### Variables & Outputs
- **Variables** (`variables.tf`): Input parameters for your configuration
- **Outputs** (`outputs.tf`): Values returned after deployment
- Makes configurations reusable and flexible

### State Management
```bash
terraform state list          # List all resources
terraform state show RESOURCE # Show specific resource state
terraform state rm RESOURCE   # Remove from state (dangerous!)
terraform refresh             # Update state from real infrastructure
```

---

## 🔒 Security Best Practices

1. **Protect Sensitive Data:**
   ```hcl
   variable "portainer_password" {
     type      = string
     sensitive = true
   }
   ```

2. **Use `.gitignore` for Secrets:**
   ```
   terraform.tfvars
   .terraform/
   *.tfstate
   *.tfstate.backup
   ```

3. **Use Terraform Cloud for State:**
   - Remote state with encryption
   - Team collaboration features
   - Better security than local state

4. **Rotate Credentials Regularly:**
   - Change Portainer API tokens periodically
   - Update passwords in a secure manner

---

## 🐛 Troubleshooting

### Common Issues

**Issue: "Provider error: dial refused"**
- Check Portainer is running and accessible
- Verify URL and credentials in `terraform.tfvars`
- Check firewall rules

**Issue: "Container already exists"**
```bash
# Remove from Terraform state and try again
terraform state rm docker_container.APP_NAME
terraform apply
```

**Issue: "Volume in use by container"**
- Ensure container is stopped: `docker stop CONTAINER_ID`
- Or create a new volume with a different name

**Issue: "Terraform plan hangs"**
- Increase timeout in configuration
- Check Docker API availability
- Verify network connectivity to Portainer

### Debug Mode

Enable verbose logging:
```bash
TF_LOG=DEBUG terraform plan
TF_LOG=TRACE terraform apply
```

---

## 📚 Further Learning

### Recommended Topics to Explore:
1. **Terraform Modules** - Reusable configuration blocks
2. **Remote State** - Terraform Cloud integration
3. **Advanced Networking** - Custom bridge networks, overlays
4. **Infrastructure Scaling** - Deploying multiple instances
5. **CI/CD Integration** - Automated deployments

### Resources:
- [Terraform Official Documentation](https://www.terraform.io/docs)
- [Docker Provider Documentation](https://registry.terraform.io/providers/kreuzwerker/docker/latest)
- [Portainer API Documentation](https://docs.portainer.io/api/client)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides)

---

## 💡 Tips & Tricks

### Useful Commands:
```bash
# Format Terraform files properly
terraform fmt -recursive

# Validate syntax without checking credentials
terraform validate

# Create plan and save to file
terraform plan -out=tfplan

# Apply saved plan
terraform apply tfplan

# Show specific resource details
terraform show docker_container.APP_NAME

# Count resources by type
terraform state list | grep docker_ | wc -l
```

### Quick Reference:
- `terraform init` - Initialize working directory
- `terraform plan` - Preview changes
- `terraform apply` - Apply changes to infrastructure
- `terraform destroy` - Remove all managed resources
- `terraform validate` - Check configuration syntax
- `terraform fmt` - Format configuration files

---

## 🎓 Workshop Completion Checklist

- [ ] Terraform installed and verified
- [ ] Portainer connection configured
- [ ] Nginx stack deployed successfully
- [ ] Web application container running
- [ ] SQLite database initialized with persistent storage
- [ ] All three components communicating
- [ ] Infrastructure successfully destructed
- [ ] Terraform state properly managed
- [ ] `.gitignore` configured for sensitive files

## 🚀 Next Steps After Workshop

Congratulations on completing the Terraform workshop! Here are suggested next steps:

1. **Enhance the Configuration:**
   - Add more services (Redis, PostgreSQL)
   - Configure advanced networking
   - Implement auto-scaling

2. **Production Readiness:**
   - Set up remote state management
   - Implement automated testing
   - Create deployment pipelines

3. **Explore Cloud Providers:**
   - Deploy to AWS, Azure, or GCP
   - Implement multi-environment setups
   - Practice infrastructure scaling

4. **Contribute Back:**
   - Share your learnings
   - Improve workshop materials
   - Help others get started

**Happy learning! 🎉**
