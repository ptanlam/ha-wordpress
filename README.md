# HA WordPress Infrastructure

This project provisions a highly available (HA) WordPress deployment using Terraform and Ansible. It is designed for AWS, but can be adapted to other cloud providers.

## High-Level Design

![HA WordPress Architecture Diagram](assets/high-level-architecture.png)

**Architecture Overview:**

- **VPC (Multi-AZ):** Main and failover subnets for high availability.
- **Route53 DNS:** Health checks and failover routing between main and failover ALBs.
- **ALB (Application Load Balancer):** In public subnets, routes HTTP/HTTPS traffic to web servers.
- **Auto Scaling Group (ASG):** EC2 web servers in private subnets, managed by a launch template.
- **RDS MySQL (Multi-AZ):** Managed database with automatic failover.
- **S3 Buckets:** For playbooks, logs, and static assets, with cross-region replication for DR.
- **IAM:** Roles for S3 replication, EC2, and least-privilege access.
- **Ansible:** Installs and configures Apache, PHP, and WordPress on EC2 instances.

## Design Overview

- **Terraform** provisions all AWS infrastructure:
  - **Networking:** VPC, public/private/database subnets, NAT gateways
  - **Compute:** Auto Scaling Group (ASG) for EC2 web servers (Amazon Linux 2023)
  - **Load Balancing:** ALB in each region/subnet for web traffic
  - **Database:** RDS MySQL (multi-AZ, managed, with failover)
  - **S3 Buckets:** For Ansible playbooks, logs, and static assets, with cross-region replication
  - **IAM:** Roles for S3 replication, EC2, and least-privilege access
  - **Route53:** DNS zone, health checks, and failover routing between main and failover ALBs
- **Ansible** configures EC2 web servers:
  - Installs Apache, PHP, and WordPress
  - Configures WordPress with environment-specific settings (from variables)
  - Handles service restarts, permissions, and Apache configuration

## Directory Structure

- `terraform/` — Infrastructure as Code (IaC) for AWS resources
  - `main.tf`, `variables.tf`, etc.: Root configuration
  - `modules/`: Reusable Terraform modules (networking, database, webservers, etc.)
  - `_tfvars/`: Environment-specific variable files
- `ansible/` — Playbooks and roles for server configuration
  - `wordpress-install.yml`: Main playbook
  - `roles/wordpress/`: Role for WordPress setup (tasks, templates, handlers, etc.)

## Deployment Steps

### Prerequisites

Before you begin, ensure you have:

- An AWS account with appropriate permissions to create and manage VPCs, EC2, RDS, S3, IAM, Route53, and Image Builder resources.
- An S3 bucket already created to store the Terraform remote state (see backend configuration step below).
- AWS CLI and Terraform installed locally.

### 1. Infrastructure Provisioning (Terraform)

1. **Create the Backend Configuration File**

- Before initializing Terraform, create the backend config file (e.g., `_backend/prod.config`) with the following content:

  ```hcl
  bucket       = "REPLACE_ME"
  use_lockfile = true
  key          = "terraform.state"
  region       = "us-east-1"
  ```

2. **Initialize Terraform**

   ```sh
   cd terraform
   terraform init -backend-config="_backend/prod.config"
   ```

3. **Select Environment Variables**

   - Edit or use the appropriate tfvars file in `_tfvars/` (e.g., `prod.tfvars`)

4. **Plan and Apply**

   ```sh
   terraform plan -var-file="_tfvars/prod.tfvars"
   terraform apply -var-file="_tfvars/prod.tfvars"
   ```

### 2. Create the AMI (Image Builder)

1. **Trigger the Image Builder Pipeline**

   - Use the AWS Console or CLI to start the EC2 Image Builder pipeline that creates the custom AMI for your web servers.
   - Example CLI command:

     ```sh
     aws imagebuilder start-image-pipeline-execution --image-pipeline-arn <your-pipeline-arn>
     ```

   - Wait for the pipeline to complete and note the resulting AMI ID.
   - Update your Terraform variables or environment to use the new AMI ID for the webserver launch template.

## Example tfvars Configuration

Below is an example of a `tfvars` file for production, combining values from `common.tfvars` and `prod.tfvars`:

```hcl
app_name = "ha-wordpress"

environment = "prod"

region = {
  main     = "us-east-1"
  failover = "us-west-1"
}

playbook_bucket = {
  replica_enabled = true
}

vpc = {
  cidr = "10.0.0.0/16"

  azs          = ["us-east-1a", "us-east-1b"]
  failover_azs = ["us-west-1a", "us-west-1c"]

  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
}

database = {
  instance_class    = "db.t3.micro"
  allocated_storage = 5
  db_name           = "app"
  username          = "app_admin"
  password          = "REPLACE_ME_WITH_A_SECURE_PASSWORD"
}

webserver = {
  instance_type    = "t3.micro"
  desired_capacity = 2
  max_size         = 2
  min_size         = 2
}

dns_name = "ha.wordpress"
```

### 2. Configuration Management (Ansible)

After modifying the Ansible configuration (playbooks, roles, or templates), you only need to re-apply Terraform. The latest Ansible content will be uploaded to the S3 bucket and used by the EC2 instances at launch or during configuration runs. There is no need to rebuild the AMI unless you change the base OS or system-level packages.

**To re-apply:**

```sh
cd terraform
terraform apply -var-file="_tfvars/prod.tfvars"
```
