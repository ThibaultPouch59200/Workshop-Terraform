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
   ├── README.md                    # This file (workshop guide)
   ├── .gitignore                   # Git ignore file
   ├── docker/                      # Docker configurations
   │   ├── README.md                # Docker documentation
   │   ├── build.sh                 # Build script for web app
   │   ├── docker-compose-full.yml  # Complete stack deployment
   │   ├── webapp/                  # Web application
   │   │   ├── Dockerfile           # Image build configuration
   │   │   ├── app.py               # Flask application
   │   │   ├── requirements.txt     # Python dependencies
   │   │   └── README.md            # Web app docs
   │   ├── nginx/                   # Nginx reverse proxy
   │   │   ├── docker-compose.yml   # Nginx stack
   │   │   ├── nginx.conf           # Nginx config
   │   │   └── README.md            # Nginx docs
   │   └── sqlite/                  # SQLite database
   │       ├── docker-compose.yml   # SQLite stack
   │       ├── init.sql             # Database initialization
   │       └── README.md            # SQLite docs
   └── terraform/                   # Terraform configurations (to be created)
       ├── main.tf                  # Main configuration
       ├── variables.tf             # Variable declarations
       ├── outputs.tf               # Output definitions
       └── docker_provider.tf       # Docker provider setup
   ```

### Step 3: Build the Web Application Image

Before starting the Terraform exercises, you need to build the Docker image for the web application.

**Option 1: Using the Build Script (Recommended)**
```bash
cd docker
./build.sh
```

**Option 2: Manual Build**
```bash
cd docker/webapp
docker build -t workshop-webapp:latest .
```

**Verify the Image:**
```bash
docker images | grep workshop-webapp
```

### Step 4: Test the Application Locally (Optional)

You can test the complete stack locally before deploying via Terraform:

```bash
# From the docker directory
cd docker
docker-compose -f docker-compose-full.yml up -d

# Test the application
curl http://localhost
curl http://localhost/health
curl http://localhost/api/info

# Clean up
docker-compose -f docker-compose-full.yml down
```

### Step 5: Prepare for Portainer Deployment

**Push Image to Portainer:**

1. **Option A: Save and Upload**
   ```bash
   docker save workshop-webapp:latest | gzip > workshop-webapp.tar.gz
   # Upload via Portainer UI: Images → Import
   ```

2. **Option B: Use a Registry**
   ```bash
   # Tag for your registry
   docker tag workshop-webapp:latest your-registry/workshop-webapp:latest

   # Push to registry
   docker push your-registry/workshop-webapp:latest
   ```

3. **Option C: Use Portainer's Local Build** (if supported)
   - Upload the Dockerfile and app files
   - Build directly in Portainer

## 📝 Workshop Exercises

Now that you have the environment set up and the web application image built, you're ready to start deploying with Terraform! Follow the exercises in [`exercises.md`](exercises.md) to deploy each component step-by-step and understand how Terraform manages your infrastructure.

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
