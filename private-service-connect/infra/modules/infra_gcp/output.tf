output "proxy_server_ip" {
  value = google_compute_address.proxy_static_ip.address
}