# Vaultwarden on GCP - Fully Automated with Terraform

This repository deploys a secure, encrypted, self-hosted password manager (Vaultwarden) on Google Cloud Platform using Terraform (Infrastructure as Code).

This setup is designed so any organization with small-medium scale password management requirements across multiple teams can deploy and manage Vaultwarden without prior experience with Terraform, cloud infrastructure, or command-line tooling. All steps assume a clean macOS system (although the same is absolutely compatible and configured for Windows OS) with no prior tooling installed.

**This deployment creates real GCP infrastructure and may incur costs. [[Disclaimer](#disclaimer)]**

<br>

## What This Setup Provides

- Self-hosted Vaultwarden server  
- GCP Compute Engine deployment
- Automatic HTTPS using sslip.io  
- Infrastructure fully managed using Terraform  
- Free-tier compatible instance type (e2-micro)
- Secure admin panel protected using token authentication  
- Fully reproducible deployment from code  

<br>

## Important Preconditions

- You must have a GCP account with billing enabled
- You must have Owner or Editor permissions on the GCP project
- Secrets must never be committed to GitHub  
- This repository is already configured to prevent secret leaks  
- GCP usage may incur monthly charges (~$3-9/month, potentially free with free tier)

<br>

## Part 1 - Install Required Tools

Choose your operating system below:

<details>
<summary><b>macOS Installation</b></summary>

### 1. Install Homebrew

Open **Terminal** and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Restart Terminal after installation completes.

Verify the installation:

```bash
brew --version
```

### 2. Install Git, Terraform, and gcloud CLI

Run:

```bash
brew install git terraform google-cloud-sdk
```

Verify each installation:

```bash
git --version
terraform --version
gcloud --version
```

Each command must return a valid version number.

</details>

<details>
<summary><b>Windows Installation</b></summary>

### 1. Install Chocolatey (Package Manager)

Open **PowerShell** as Administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Close and reopen PowerShell as Administrator.

Verify the installation:

```powershell
choco --version
```

### 2. Install Git, Terraform, and gcloud CLI

Run:

```powershell
choco install git terraform gcloudsdk -y
```

Close and reopen PowerShell (as regular user).

Verify each installation:

```powershell
git --version
terraform --version
gcloud --version
```

Each command must return a valid version number.

**Alternative (Manual Installation):**
- Git: [Download from git-scm.com](https://git-scm.com/download/win)
- Terraform: [Download from terraform.io](https://developer.hashicorp.com/terraform/downloads)
- gcloud CLI: [Download from Google Cloud](https://cloud.google.com/sdk/docs/install#windows)

</details>

<details>
<summary><b>Linux Installation (Ubuntu/Debian)</b></summary>

### 1. Update Package Manager

Open **Terminal** and run:

```bash
sudo apt update
```

### 2. Install Git

```bash
sudo apt install git -y
```

Verify:

```bash
git --version
```

### 3. Install Terraform

```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
sudo apt update && sudo apt install terraform -y
```

Verify:

```bash
terraform --version
```

### 4. Install gcloud CLI

```bash
# Add Google Cloud SDK repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Add GPG key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install gcloud CLI
sudo apt update && sudo apt install google-cloud-cli -y
```

Verify:

```bash
gcloud --version
```

</details>

<details>
<summary><b>Linux Installation (Fedora/RHEL/CentOS)</b></summary>

### 1. Update Package Manager

```bash
sudo dnf update -y
```

### 2. Install Git

```bash
sudo dnf install git -y
```

Verify:

```bash
git --version
```

### 3. Install Terraform

```bash
# Add HashiCorp repository
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

# Install Terraform
sudo dnf install terraform -y
```

Verify:

```bash
terraform --version
```

### 4. Install gcloud CLI

```bash
# Add Google Cloud SDK repository
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

# Install gcloud CLI
sudo dnf install google-cloud-cli -y
```

Verify:

```bash
gcloud --version
```

</details>

<br>

## Part 2 - GCP Account Setup (One-Time)

### 3. Create or Select a GCP Project

1. Go to [GCP Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your **Project ID** (not the project name)
4. Enable billing for the project

### 4. Enable Required APIs

Run the following commands to enable necessary APIs:

```bash
gcloud config set project YOUR-PROJECT-ID

gcloud services enable compute.googleapis.com
```

### 5. Authenticate with GCP

Run:

```bash
gcloud auth application-default login
```

This will open a browser window for authentication. Complete the OAuth flow.

Verify authentication:

```bash
gcloud auth list
```

You should see your account email marked with an asterisk (*).

<br>

## Part 3 - SSH Key Setup

### 6. Generate SSH Key Pair

<details>
<summary><b>macOS / Linux</b></summary>

If you don't already have an SSH key, generate one:

```bash
ssh-keygen -t rsa -b 4096 -C "vaultwarden@gcp" -f ~/.ssh/vaultwarden-gcp
```

Press Enter to accept defaults (no passphrase for automated access).

View your public key:

```bash
cat ~/.ssh/vaultwarden-gcp.pub
```

Copy this entire output — you'll need it for `terraform.tfvars`.

</details>

<details>
<summary><b>Windows (PowerShell)</b></summary>

If you don't already have an SSH key, generate one:

```powershell
ssh-keygen -t rsa -b 4096 -C "vaultwarden@gcp" -f $env:USERPROFILE\.ssh\vaultwarden-gcp
```

Press Enter to accept defaults (no passphrase for automated access).

View your public key:

```powershell
Get-Content $env:USERPROFILE\.ssh\vaultwarden-gcp.pub
```

Copy this entire output — you'll need it for `terraform.tfvars`.

**Note:** If `ssh-keygen` is not found, ensure Git is installed (it includes OpenSSH) or install [OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse).

</details>

<br>

## Part 4 - Obtain the Source Code

### 7. Clone the Repository

```bash
git clone https://github.com/unneal/vaultwarden-terraform
cd vaultwarden-terraform
```

<br>

## Part 5 - Secure Deployment Configuration

### 8. Create Terraform Variables File

Create a file named `terraform.tfvars` (this file is gitignored):

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
gcp_project_id = "your-gcp-project-id"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

machine_type = "e2-micro"

ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EA... your-email@example.com"

admin_token = "YOUR-GENERATED-SECURE-TOKEN-HERE"
```

### 9. Generate Secure Admin Token

Generate a secure admin token:

```bash
openssl rand -hex 32
```

Copy the output and replace `admin_token` in `terraform.tfvars`.

**This file must never be committed to version control.**

<br>

## Part 6 - Deploy Vaultwarden

### 10. Initialize Terraform

```bash
terraform init
```

### 11. Preview Infrastructure

```bash
terraform plan
```

Review the resources that will be created:
- Compute Engine instance (e2-micro)
- Firewall rule (HTTPS access)

### 12. Deploy Infrastructure

```bash
terraform apply
```

When prompted, type: `yes`

Deployment takes approximately 3-5 minutes.

After completion, Terraform will output:

```
public_ip = "34.xxx.xxx.xxx"
vaultwarden_url = "https://34.xxx.xxx.xxx.sslip.io"
ssh_command = "gcloud compute ssh ubuntu@vaultwarden --zone=us-central1-a"
```

<br>

## Part 7 - Initial Vaultwarden Setup

### 13. Wait for Services to Start

After `terraform apply` completes, wait 2-3 minutes for Docker services to fully initialize.

### 14. Open Vaultwarden

Open the provided HTTPS URL in a browser (from `vaultwarden_url` output).

### 15. Create the First User Account

1. Click **Create Account**
2. Enter your email and master password
3. Log in with your credentials

### 16. Access the Admin Panel

Navigate to the admin URL (from `vaultwarden_url` output + `/admin`).

Enter the admin token you generated earlier.

**Important Admin Actions:**

- Disable public signups after creating necessary accounts
- Configure organizational policies
- Review security settings

<br>

## Part 8 - Health Verification

Confirm all of the following:

✓ Login works  
✓ Vault entries can be created  
✓ HTTPS encryption is active (padlock in browser)  
✓ Application remains stable across refreshes  
✓ Admin panel is accessible with token  

<br>

## Part 9 - Cost Awareness

This deployment includes:

- One e2-micro Compute Engine instance (~$6-7/month)
- 10 GB standard persistent disk (~$0.40/month)
- Ephemeral external IP address (free)
- Minimal egress traffic

**Estimated monthly cost: ~$6-8 USD**

**GCP Free Tier includes:**
- 1 e2-micro instance in select regions (us-west1, us-central1, us-east1)
- 30 GB-months standard persistent disk
- 1 GB network egress per month

If you stay within free tier limits and use us-central1, costs may be **$0-3/month**.

<br>

## Part 10 - Destroying Infrastructure

To permanently delete all deployed resources:

```bash
terraform destroy
```

Confirm by typing: `yes`

**⚠️ This permanently deletes the server and all stored vault data.**

<br>

## Part 11 - Common Issues

### Issue: "Error 403: Compute Engine API has not been used"

**Solution:**

```bash
gcloud services enable compute.googleapis.com
```

### Issue: "SSH key not working"

**Solution:**

Ensure your public key in `terraform.tfvars` is the complete output of:

```bash
cat ~/.ssh/vaultwarden-gcp.pub
```

The format should be: `ssh-rsa AAAAB3NzaC1... user@hostname`

### Issue: "Page loads indefinitely"

**Solution:**

Wait 3-5 minutes after `terraform apply` for Docker services to complete setup.

Check logs:

```bash
gcloud compute ssh ubuntu@vaultwarden --zone=us-central1-a
sudo journalctl -u google-startup-scripts -f
```

### Issue: "Admin token not working"

**Solution:**

Verify the token in `terraform.tfvars` matches exactly what you're entering (no extra spaces or quotes).

<br>

## Part 12 - Maintenance

### Viewing Logs

```bash
gcloud compute ssh ubuntu@vaultwarden --zone=us-central1-a
sudo docker logs -f vaultwarden
```

### Updating Vaultwarden

```bash
gcloud compute ssh ubuntu@vaultwarden --zone=us-central1-a
cd /
sudo docker pull vaultwarden/server:latest
sudo docker stop vaultwarden
sudo docker rm vaultwarden
# Container will restart automatically via startup script on next boot
sudo reboot
```

### Backup Data

The vault data is stored in `/vw-data` on the VM.

To create a backup:

```bash
gcloud compute ssh ubuntu@vaultwarden --zone=us-central1-a
sudo tar -czf vaultwarden-backup-$(date +%Y%m%d).tar.gz /vw-data
```

Download backup to local machine:

```bash
gcloud compute scp ubuntu@vaultwarden:~/vaultwarden-backup-*.tar.gz . --zone=us-central1-a
```

<br>

## Security Recommendations

1. **Restrict SSH access**: Update firewall rule to allow only your IP
2. **Enable 2FA**: Configure two-factor authentication for all users
3. **Regular backups**: Automate vault data backups to Google Cloud Storage
4. **Monitor logs**: Set up GCP logging and monitoring alerts
5. **Disable signups**: After creating accounts, disable public registration
6. **Use custom domain**: Configure a real domain instead of sslip.io
7. **Review service account permissions**: Use least-privilege principles

### Security Features Implemented

This deployment follows security best practices:

✅ **Custom Service Account** - Minimal permissions (logging only, no compute/storage access)  
✅ **Shielded VM** - vTPM and integrity monitoring enabled  
✅ **Instance-Specific SSH Keys** - Project-wide SSH keys disabled  
✅ **HTTPS-Only Access** - All traffic encrypted via Caddy + Let's Encrypt  
✅ **Encrypted Storage** - Boot disk encrypted at rest (Google-managed keys)  
✅ **Token-Based Admin Access** - Admin panel protected by secure token  
✅ **Firewall Restrictions** - Only HTTPS (port 443) accessible from internet  

### Security Validation

This infrastructure has been validated with [tfsec](https://github.com/aquasecurity/tfsec) security scanner:

```bash
# Run security scan
tfsec .

# Expected result: 7 passed, 4 ignored, 0 potential problems
```

All ignored issues are intentional design decisions (public access for password manager service) with appropriate mitigations in place.

<br>

## Checklist

- [ ] Install Homebrew
- [ ] Install Git, Terraform, gcloud CLI
- [ ] Create or select GCP project
- [ ] Enable Compute Engine API
- [ ] Authenticate with `gcloud auth application-default login`
- [ ] Generate SSH key pair
- [ ] Clone repository
- [ ] Create and configure `terraform.tfvars`
- [ ] Generate secure admin token
- [ ] Run `terraform init`
- [ ] Run `terraform plan`
- [ ] Run `terraform apply`
- [ ] Wait 3-5 minutes for services
- [ ] Access Vaultwarden URL
- [ ] Create first user account
- [ ] Access admin panel
- [ ] Disable public signups
- [ ] Enable 2FA for users

<br>

## Intended Users

This repository is designed for:

- Organizations needing secure password management
- Users with no Terraform or GCP background
- Compliance-aligned infrastructure deployment
- Cost-conscious deployments leveraging GCP free tier
- Community Dreams Foundation internal security team

<br>

## Architecture

```
Internet
    |
    v
[GCP Firewall Rule]
    |
    +-- Allow HTTPS (443)
    |
    v
[Compute Engine Instance - e2-micro]
    |
    +-- Caddy (Reverse Proxy + Auto HTTPS)
    |       |
    |       v
    +-- Vaultwarden (Docker Container)
            |
            v
    [Persistent Disk: /vw-data]
```

<br>

## Technical Details

- **OS**: Ubuntu 22.04 LTS
- **Docker**: Latest stable
- **Vaultwarden**: Latest from Docker Hub
- **Reverse Proxy**: Caddy (automatic HTTPS)
- **SSL**: Automatic via sslip.io + Let's Encrypt
- **Network**: Default VPC
- **Firewall**: HTTPS-only ingress

<br>

## Migrating from AWS

If you're migrating from the AWS version of this deployment:

1. **Backup your AWS vault data** before destroying
2. **Export vault data** from AWS Vaultwarden admin panel
3. Deploy GCP infrastructure using this repository
4. **Import vault data** to GCP Vaultwarden admin panel
5. Verify all data migrated successfully
6. Destroy AWS infrastructure

<br>

## Migrating from GCP to AWS

This repository includes AWS deployment templates as backup files (`.aws.example` extension). To migrate from GCP back to AWS:

### Quick Migration Steps:

1. **Backup your GCP vault data** (export from admin panel)

2. **Replace Terraform files** with AWS versions:
   ```bash
   cp provider.tf.aws.example provider.tf
   cp variables.tf.aws.example variables.tf
   cp compute.tf.aws.example compute.tf
   cp network.tf.aws.example network.tf
   cp security.tf.aws.example security.tf
   cp outputs.tf.aws.example outputs.tf
   ```

3. **Setup AWS CLI and credentials**:
   ```bash
   brew install awscli
   aws configure
   # Enter AWS Access Key ID, Secret Access Key, region (us-east-1)
   ```

4. **Create EC2 SSH key pair**:
   ```bash
   aws ec2 create-key-pair \
     --key-name vaultwarden-key \
     --query "KeyMaterial" \
     --output text > vaultwarden-key.pem
   chmod 400 vaultwarden-key.pem
   ```

5. **Create `terraform.tfvars` for AWS**:
   ```hcl
   aws_region    = "us-east-1"
   instance_type = "t3.micro"
   key_name      = "vaultwarden-key"
   admin_token   = "your-secure-token"
   ```

6. **Clean state and deploy**:
   ```bash
   rm terraform.tfstate*
   terraform init -upgrade
   terraform plan
   terraform apply
   ```

7. **Import vault data** to AWS Vaultwarden instance

8. **Destroy GCP infrastructure** once verified:
   ```bash
   # Switch back to GCP files temporarily
   terraform destroy
   ```

### AWS Setup Requirements:

- AWS account with billing enabled
- IAM user with EC2, VPC permissions
- AWS CLI configured with credentials
- EC2 key pair created in target region

The `.aws.example` files contain the complete AWS deployment configuration and can be used as-is after renaming.

<br>

## Refer

- [Vaultwarden](https://github.com/dani-garcia/vaultwarden/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Google Cloud Platform Documentation](https://docs.cloud.google.com/docs)

<br>

## Contributors

[![Contributors Avatars](https://contributors-img.web.app/image?repo=unneal/vaultwarden-terraform)](https://github.com/unneal/vaultwarden-terraform/graphs/contributors)

<br>

## Disclaimer

**This project is not associated or affiliated in any manner with [Vaultwarden](https://github.com/dani-garcia/vaultwarden/), [Bitwarden](https://bitwarden.com/), or Bitwarden, Inc.**

This is a personal project created to fulfill specific infrastructure deployment needs.

**Please note:** Review all code before use. The authors/contributors of this repository cannot be held liable for any issues, losses, or damages that may occur from the use of this infrastructure. This includes, but is not limited to, cloud service provider billing costs, passwords, attachments, and other sensitive information handled by the deployed services.

<br>

## License

MIT License - See LICENSE file for details