resource "google_compute_firewall" "vaultwarden_https" {
  name    = "vaultwarden-allow-https"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  # tfsec:ignore:google-compute-no-public-ingress - Public access required for password manager service
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vaultwarden"]
  description   = "Allow HTTPS access to Vaultwarden from anywhere"
}