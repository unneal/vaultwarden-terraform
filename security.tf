resource "google_compute_firewall" "vaultwarden_https" {
  name    = "vaultwarden-allow-https"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vaultwarden"]
  description   = "Allow HTTPS access to Vaultwarden"
}