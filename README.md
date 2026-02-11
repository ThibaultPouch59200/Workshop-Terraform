# Terraform Workshop: Infrastructure as Code with Portainer

## Workshop Overview

Welcome to the **Terraform Workshop**! This hands-on learning experience will guide you through the fundamentals of Terraform by building a simple yet practical infrastructure. You'll learn how to use **Infrastructure as Code (IaC)** principles to deploy a containerized web application stack on a Portainer-hosted Docker environment.

By the end of this workshop, you'll understand how to:
- Write Terraform configurations to manage infrastructure
- Deploy multi-container applications using Terraform
- Manage Docker stacks and services through code
- Apply best practices for reproducible infrastructure

---

## Learning Objectives

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

## Architecture Overview

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

## Prerequisites

### System Requirements
- Docker Desktop (Windows/Mac) or Docker Engine (Linux) installed and running
- At least 4GB of RAM available for Docker
- Basic understanding of Docker concepts (containers, images, networking)

### Software Requirements
- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
  - [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Terraform** (version 1.0+) installed on your local machine
  - [Download Terraform](https://developer.hashicorp.com/terraform/tutorials/docker-get-started/install-cli)
- A text editor or IDE (VS Code recommended)

### Knowledge Requirements
- Familiarity with command line/terminal
- Basic understanding of Docker containers
- No Terraform experience needed - we'll learn together!

---

## Getting Started

### Step 1: Set Up Local Portainer

Portainer will be your local Docker management platform for this workshop.

1. **Start Portainer Container:**
   ```bash
   docker run -d \
     -p 9443:9443 \
     -p 8000:8000 \
     --name portainer \
     --restart=always \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v portainer_data:/data \
     portainer/portainer-ce:latest
   ```

2. **Access Portainer Web Interface:**
   - Open your browser to: `https://localhost:9443`
   - You may see a security warning (self-signed certificate) - accept it
   - Create your admin account on first login:
     - Username: `admin` (or your choice)
     - Password: Choose a secure password
   - When your are on the wizard to select an environment, choose **Get Started** (the default)
   - On the next screen, select **Local** to manage your local Docker environment

3. **Generate Portainer API Key:**
   - Once logged in, go to: **User settings** (click your username) → **Access tokens**
   - Click **+ Add access token**
   - Description: `Terraform Workshop`
   - Click **Add token**
   - **⚠️ IMPORTANT:** Copy the token immediately (it won't be shown again)
   - It will look like: `ptr_xxxxxxxxxxxxxxxxxxxxxxxx`

4. **Verify Environment ID:**
   - In Portainer, go to **Environments**
   - Note the ID of your local environment (usually `3` for local Docker)
   - Or hover over the environment name and check the URL `/endpoints/3` (the number is the ID)

### Step 2: Prepare Your Workspace

1. **Clone or Navigate to Workshop Repository:**
   ```bash
   cd Workshop-Terraform
   ```

2. **Create Terraform Configuration File:**

   Create a `terraform.tfvars` file in the root directory with your Portainer details:

   ```bash
   cat > terraform.tfvars << EOF
   portainer_url              = "https://localhost:9443"
   portainer_api_key          = "ptr_YOUR_TOKEN_HERE"
   portainer_skip_ssl_verify  = true
   EOF
   ```

   Replace `ptr_YOUR_TOKEN_HERE` with the API token you copied in Step 2.

   **⚠️ Security Note:** Never commit `terraform.tfvars` to version control! It's already in `.gitignore`.

   **Using a Custom tfvars File:**

   After you create the `terraform.tfvars` file, you can specify it explicitly when running Terraform commands:

   ```bash
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

   or set the environment variable to automatically use it:

   ```bash
   export TF_VAR_file="terraform.tfvars"
   ```

3. **Review the Project Structure:**
   ```
   Workshop-Terraform/
   ├── README.md              # This file (workshop guide)
   ├── exercises.md           # Step-by-step exercises
   ├── .gitignore            # Git ignore file
   ├── provider.tf           # Portainer provider configuration
   ├── variables.tf          # Variable declarations
   ├── entrypoint.tf         # Main entry point
   ├── terraform.tfvars      # Your local config (not in git)
   └── stacks/               # Individual stack configurations
       ├── nginx/            # Nginx reverse proxy
       ├── app/              # Web application
       └── sqlite/           # SQLite database
   ```

## Workshop Exercises

Now that you have the environment set up and the web application image built, you're ready to start deploying with Terraform! Follow the exercises in [`exercises.md`](exercises.md) to deploy each component step-by-step and understand how Terraform manages your infrastructure.

---

## Key Terraform Concepts

### State Files
- `terraform.tfstate`: Tracks current infrastructure state
- Keep this file safe and backed up
- Never manually edit this file
- Consider remote state for team environments

### Providers
- Terraform plugins that interact with APIs (Docker, AWS, Azure, etc.)
- Configured in `provider.tf`
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

3. **Rotate Credentials Regularly:**
   - Change Portainer API tokens periodically
   - Update passwords in a secure manner

---

## Troubleshooting

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

## Further Learning

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

## Tips & Tricks

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

## Workshop Completion Checklist

- [ ] Terraform installed and verified
- [ ] Portainer connection configured
- [ ] Nginx stack deployed successfully
- [ ] Web application container running
- [ ] SQLite database initialized with persistent storage
- [ ] All three components communicating
- [ ] Infrastructure successfully destructed
- [ ] Terraform state properly managed
- [ ] `.gitignore` configured for sensitive files

## Next Steps After Workshop

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
