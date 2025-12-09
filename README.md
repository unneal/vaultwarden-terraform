# Vaultwarden on AWS — Fully Automated with Terraform (CDF Internal)

This repository deploys a secure, encrypted, self-hosted password manager (Vaultwarden) on AWS using Terraform (Infrastructure as Code).

This setup is designed so the CDF internal team can deploy and manage Vaultwarden without prior experience with Terraform, cloud infrastructure, or command-line tooling. All steps assume a clean macOS system with no prior tooling installed.

This deployment creates real AWS infrastructure and may incur costs.

---

## What This Setup Provides

- Self-hosted Vaultwarden server  
- AWS EC2-based deployment  
- Automatic HTTPS using sslip.io  
- Infrastructure fully managed using Terraform  
- Free-tier compatible instance type (t3.micro)  
- Secure admin panel protected using token authentication  
- Fully reproducible deployment from code  

---

## Important Preconditions

- You must have access to the AWS root account or an IAM administrator account  
- Secrets must never be committed to GitHub  
- This repository is already configured to prevent secret leaks  
- AWS usage may incur monthly charges  

---

## Part 1 — Install Required Tools on macOS

These steps assume a completely fresh Mac environment.

### 1. Install Homebrew

Open **Terminal** and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


Restart Terminal after installation completes.

Verify the installation:

brew --version

### 2. Install Git, Terraform, and AWS CLI

Run:

brew install git terraform awscli


Verify each installation:

git --version
terraform --version
aws --version


Each command must return a valid version number.


## Part 2 — AWS Account Setup (One-Time)
### 3. Create an IAM User for Terraform

Log in to the AWS Console as the root user.

Navigate to:

IAM → Users → Create user


Example username:

terraform-cdf


Enable Programmatic access.

Attach the following policies:

AmazonEC2FullAccess

AmazonVPCFullAccess

AmazonS3FullAccess

IAMReadOnlyAccess

Complete user creation.

Download the Access Key ID and Secret Access Key immediately.
The secret key cannot be retrieved again.

### 4. Configure AWS Credentials Locally

In Terminal, run:

aws configure


Enter the following:

AWS Access Key ID

AWS Secret Access Key

Region: us-east-1

Output format: json

Verify authentication:

aws sts get-caller-identity


This must return your AWS account ID and IAM username.


## Part 3 — Obtain the Source Code
### 5. Clone the Repository
git clone https://github.com/unneal/vaultwarden-terraform
cd vaultwarden-terraform


## Part 4 — Secure Deployment Configuration
### 6. Create Terraform Variables File

Create a file named:

terraform.tfvars


Add the following contents:

aws_region    = "us-east-1"
instance_type = "t3.micro"
key_name      = "vaultwarden-key"
admin_token   = "REPLACE-WITH-A-LONG-RANDOM-SECURE-TOKEN"


Generate a secure admin token using:

openssl rand -hex 32


Replace the placeholder with the generated value.

This file is intentionally ignored by Git and must never be committed.

### 7. Create EC2 SSH Key Pair

Run:

aws ec2 create-key-pair \
  --key-name vaultwarden-key \
  --query "KeyMaterial" \
  --output text > vaultwarden-key.pem


Secure the key file:

chmod 400 vaultwarden-key.pem


## Part 5 — Deploy Vaultwarden
### 8. Initialize Terraform
terraform init

### 9. Preview Infrastructure
terraform plan


Review the resources that will be created.

### 10. Deploy Infrastructure
terraform apply


When prompted, type:

yes


After 2–4 minutes, Terraform will output a public IP address and Vaultwarden URL.

Example:

vaultwarden_url = "https://18.xxx.xxx.xxx.sslip.io"


## Part 6 — Initial Vaultwarden Setup
### 11. Open Vaultwarden

Open the provided HTTPS URL in a browser.

### 12. Create the First User Account

Click Create Account and log in.

### 13. Access the Admin Panel

Navigate to:

https://YOUR-IP.sslip.io/admin


Enter the admin token created earlier.

Inside the admin panel:

Disable public signups

Configure organizational policies if required


## Part 7 — Health Verification
Confirm all of the following:

Login works

Vault entries can be created

HTTPS encryption is active

Application remains stable across refreshes


## Part 8 — Cost Awareness
This deployment includes:

One t3.micro EC2 instance

No load balancer

No managed database

Minimal attached storage

Estimated monthly cost is approximately USD 6–9.


## Part 9 — Destroying Infrastructure
To permanently delete all deployed resources:

terraform destroy


Confirm by typing:

yes


This permanently deletes the server and all stored data.


## Part 10 — Common Issues
Instance Type Not Allowed

Ensure:

instance_type = "t3.micro"

Key Pair Not Found

Run:

aws ec2 describe-key-pairs


If missing, re-create the key.

Vaultwarden Page Loads Indefinitely

Wait 2–3 minutes after deployment for Docker services to complete first-time setup.

Intended Users

This repository is designed for:

CDF internal security team

Users with no Terraform or AWS background

Secure organizational credential storage

Cloud-hosted password management

Compliance-aligned infrastructure deployment


Author:
Anil Kumar Gorthi
Cybersecurity Analyst — Internal Security Team
Community Dreams Foundation (CDF)