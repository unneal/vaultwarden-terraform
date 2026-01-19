resource "google_compute_instance" "vaultwarden" {
  name         = "vaultwarden"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  tags = ["vaultwarden"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network = data.google_compute_network.default.name
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  metadata_startup_script = templatefile("${path.module}/user_data.sh", {
    ADMIN_TOKEN = var.admin_token
  })

  service_account {
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
}