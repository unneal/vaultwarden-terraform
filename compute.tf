# Create a custom service account with minimal permissions
resource "google_service_account" "vaultwarden" {
  account_id   = "vaultwarden-sa"
  display_name = "Vaultwarden Service Account"
  description  = "Service account for Vaultwarden instance with minimal permissions"
}

# tfsec:ignore:google-compute-no-project-wide-ssh-keys - Project SSH keys blocked via metadata
resource "google_compute_instance" "vaultwarden" {
  name         = "vaultwarden"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  tags = ["vaultwarden"]

  # tfsec:ignore:google-compute-vm-disk-encryption-customer-key - Google-managed encryption is sufficient for this use case
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network = data.google_compute_network.default.name
    # tfsec:ignore:google-compute-no-public-ip - Public IP required for sslip.io HTTPS access
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys               = "ubuntu:${var.ssh_public_key}"
    block-project-ssh-keys = "true" # Disable project-wide SSH keys
  }

  metadata_startup_script = templatefile("${path.module}/user_data.sh", {
    ADMIN_TOKEN = var.admin_token
  })

  service_account {
    email  = google_service_account.vaultwarden.email
    scopes = ["logging-write", "monitoring-write"] # Minimal scopes for logging only
  }

  # Enable Shielded VM features for better security
  shielded_instance_config {
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  allow_stopping_for_update = true
}