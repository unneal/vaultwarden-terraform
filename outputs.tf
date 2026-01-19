output "vaultwarden_url" {
  value = "https://${google_compute_instance.vaultwarden.network_interface[0].access_config[0].nat_ip}.sslip.io"
}

output "public_ip" {
  value = google_compute_instance.vaultwarden.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
  value = google_compute_instance.vaultwarden.name
}

output "ssh_command" {
  value = "gcloud compute ssh ubuntu@${google_compute_instance.vaultwarden.name} --zone=${var.gcp_zone}"
}