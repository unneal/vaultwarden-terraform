variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "e2-micro"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "admin_token" {
  description = "Vaultwarden admin token"
  type        = string
  sensitive   = true
}