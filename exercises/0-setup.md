# Exercise 0: Setup and Configuration

**Objective:** Set up your local environment, configure Portainer connection, and initialize Terraform

---

## Part 1: Understanding Terraform Basics

**Objective:** Get familiar with Terraform commands and workflow

### 1. Review Provided Configuration Files

Open and examine these files to understand the project structure:

- `provider.tf` - Portainer provider configuration
- `variables.tf` - Variable declarations
- `entrypoint.tf` - Module orchestration
- `stacks/nginx/provider.tf` and `variables.tf`
- `stacks/sqlite/provider.tf` and `variables.tf`
- `stacks/webapp/provider.tf` and `variables.tf`

### 2. Initialize Terraform

```bash
terraform init
```

This command:
- Creates a `.terraform` directory
- Downloads the Portainer provider plugin
- Prepares your working directory

### 3. Questions to Consider

- What is a provider in Terraform?
- What do variables do and how are they passed to modules?
- How does Terraform track state?
- What is the purpose of modules in Terraform?

## Part 2: Configure Local Portainer Connection

**Objective:** Set up authenticated connection to your local Portainer instance

### 1. Ensure Portainer is Running

```bash
docker ps | grep portainer
```

If not running, follow the README to start Portainer:

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

### 2. Get Your API Key

1. Access Portainer at `https://localhost:9443`
2. Go to **User settings** → **Access tokens**
3. Click **+ Add access token**
4. Description: `Terraform Workshop`
5. **Copy the token** (starts with `ptr_`)

⚠️ **Important:** Copy it immediately - it won't be shown again!

### 3. Create `terraform.tfvars` file

Create this file in the project root:

```hcl
portainer_url              = "https://localhost:9443"
portainer_api_key          = "ptr_YOUR_TOKEN_HERE"
portainer_skip_ssl_verify  = true
```

Replace `ptr_YOUR_TOKEN_HERE` with your actual API token.

⚠️ **Security Note:** Never commit this file to version control! It's already in `.gitignore`.

### 4. Verify Environment ID

In Portainer UI:
- Go to **Environments**
- Note the ID of your local environment (usually `3`)
- This is used in your Terraform configuration

### 5. Validate Configuration

```bash
terraform validate
```

If successful, you'll see: "Success! The configuration is valid."

## Part 3: Build the WebApp Docker Image

**Objective:** Build the custom web application image that we'll deploy

The webapp is a custom Node.js application, so we need to build its Docker image before Terraform can deploy it.

### 1. Build the Image

```bash
docker build -t workshop-webapp:latest stacks/webapp/
```

This builds the image with the tag `workshop-webapp:latest`.

### 2. Verify the Image

```bash
docker images | grep workshop-webapp
```

You should see the newly built image in the list.

**Why do this?** The webapp image isn't available on Docker Hub - it's a custom application. We build it locally, and Terraform will use this local image during deployment.

## Part 4: Create Docker Network

**Objective:** Create the shared network for container communication

All three stacks (nginx, sqlite, webapp) need to communicate on the same Docker network.

### Create the Network

```bash
docker network create --driver bridge --subnet 172.20.0.0/16 workshop-network
```

### Verify the Network

```bash
docker network ls | grep workshop
```

**Why do this?** The Docker Compose files reference this network as "external", meaning it must exist before we deploy the stacks. This allows containers to find each other by name (e.g., nginx can reach `workshop-webapp:3000`).

---

## ✅ Setup Complete!

You've successfully:

- ✅ Initialized Terraform
- ✅ Configured Portainer API access
- ✅ Built the webapp Docker image
- ✅ Created the Docker network
- ✅ Validated your Terraform configuration

**Next:** Continue to [Exercise 1: Deploy Nginx →](1-nginx.md)
