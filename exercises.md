# Terraform Workshop Exercises

Welcome to the hands-on exercises! This workshop will guide you through deploying a complete multi-tier application infrastructure using Terraform and Portainer.

## 🎯 Learning Objectives

By the end of this workshop, you will be able to:

- ✅ Understand Infrastructure as Code principles
- ✅ Configure and use the Terraform Portainer provider
- ✅ Create resource configurations with proper dependencies
- ✅ Deploy multi-container applications using Docker Compose and Terraform
- ✅ Manage infrastructure lifecycle (create, update, destroy)
- ✅ Use Terraform modules for organized infrastructure
- ✅ Handle persistent data with Docker volumes
- ✅ Configure networking between containers

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ Docker Desktop (Mac/Windows) or Docker Engine (Linux) installed and running
- ✅ Terraform installed (version 1.0+)
- ✅ Portainer running locally (see [README.md](README.md))
- ✅ Basic command line knowledge
- ✅ Text editor or IDE

---

## 📚 Workshop Structure

The workshop is organized into progressive exercises, each building on the previous one:

### Getting Started

**[Exercise 0: Setup and Configuration](exercises/0-setup.md)**
Set up your local environment, configure Portainer, and initialize Terraform.

### Core Exercises - Deploy Each Stack

**[Exercise 1: Deploy Nginx Web Server](exercises/1-nginx.md)**
Learn Terraform basics by deploying an Nginx reverse proxy from scratch.

**[Exercise 2: Deploy SQLite Database](exercises/2-sqlite.md)**
Apply your knowledge to deploy a SQLite database with persistent storage and initialization.

**[Exercise 3: Deploy Web Application](exercises/3-webapp.md)**
Complete the stack by deploying a custom Node.js web application that connects to the database.

### Advanced Exercises

**[Exercise 4: Full Infrastructure Management](exercises/4-full-infrastructure.md)**
Deploy and manage all components together, explore updates and modifications.

**[Exercise 5: Cleanup and Destroy](exercises/5-cleanup.md)**
Learn how to safely tear down infrastructure and understand lifecycle management.

---

## 📖 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Portainer API Documentation](https://docs.portainer.io/api/client)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [PORTAINER_PROVIDER_REFERENCE.md](PORTAINER_PROVIDER_REFERENCE.md) - Your go-to reference for this workshop

## 💡 Tips for Success

- **Read the complete exercise** before starting to write code
- **Use the hints** if you get stuck, but try solving it yourself first
- **Validate frequently** with `terraform validate` to catch syntax errors early
- **Understand the "why"** not just the "how" - ask questions about each resource
- **Keep PORTAINER_PROVIDER_REFERENCE.md open** for quick reference

---

Ready to begin? **[Start with Exercise 0 →](exercises/0-setup.md)**
