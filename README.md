# Vaultwarden on AWS using Terraform

This project deploys a fully self-hosted Vaultwarden password manager on AWS using:

- EC2
- Docker
- Caddy
- sslip.io automatic HTTPS
- Terraform Infrastructure as Code

## Architecture

User → HTTPS (Caddy) → Vaultwarden (Docker) → Encrypted Storage

## Setup

1. Create an AWS Key Pair
2. Copy example vars:

```bash
cp terraform.tfvars.example terraform.tfvars
