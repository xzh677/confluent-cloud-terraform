terraform {
  required_version = ">= 0.14.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

# ==== Network ====
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id   = var.gcp_project_id
  network_name = "${var.resource_prefix}-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name      = "${var.resource_prefix}-subnet"
      subnet_ip        = "10.0.0.0/16"
      subnet_region    = var.region
      subnet_flow_logs = "true"
    }
  ]
}

resource "google_compute_address" "psc_endpoint_ip" {
  for_each     = { for zone in var.subnet_name_by_zone : zone => zone }
  name         = "${var.resource_prefix}-ip-${var.cc_network_id}-${each.key}"
  subnetwork   = module.vpc.subnets_ids[0]
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "psc_endpoint_ilb" {
  for_each              = { for zone in var.subnet_name_by_zone : zone => zone }
  name                  = "${var.resource_prefix}-endpoint-${var.cc_network_id}-${each.key}"
  target                = lookup(var.cc_psc_attachments, each.key, "\n\nerror: ${each.key} subnet is missing from CCN's Private Service Connect service attachments")
  load_balancing_scheme = "" # need to override EXTERNAL default when target is a service attachment
  network               = module.vpc.network_id
  ip_address            = google_compute_address.psc_endpoint_ip[each.key].id
}

# ==== DNS ====
resource "google_dns_managed_zone" "psc_endpoint_hz" {
  name     = "${var.resource_prefix}-zone-${var.cc_network_id}"
  dns_name = "${var.cc_hosted_zone}."

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = module.vpc.network_id
    }
  }

  project = var.gcp_project_id
}

resource "google_dns_record_set" "psc_endpoint_rs" {
  name = "*.${google_dns_managed_zone.psc_endpoint_hz.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = google_dns_managed_zone.psc_endpoint_hz.name
  rrdatas = [
    for zone in var.subnet_name_by_zone : google_compute_address.psc_endpoint_ip[zone].address
  ]

}

resource "google_dns_record_set" "psc_endpoint_zonal_rs" {
  for_each = { for zone in var.subnet_name_by_zone : zone => zone }

  name = "*.${each.key}.${google_dns_managed_zone.psc_endpoint_hz.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = google_dns_managed_zone.psc_endpoint_hz.name
  rrdatas      = [google_compute_address.psc_endpoint_ip[each.key].address]

  project = var.gcp_project_id
}

# ==== Proxy ====

resource "google_compute_address" "proxy_static_ip" {
  name    = "${var.resource_prefix}-proxy"
  project = var.gcp_project_id
  region  = var.region
}

resource "google_compute_instance" "proxy_server" {
  name         = "${var.resource_prefix}-proxy-${var.cc_network_id}"
  zone         = var.subnet_name_by_zone[0]
  machine_type = var.proxy_server_type

  project = var.gcp_project_id

  tags = ["proxy"]

  boot_disk {
    initialize_params {
      image = var.proxy_server_image
    }
  }

  network_interface {
    subnetwork = module.vpc.subnets_ids[0]
    access_config {
      nat_ip = google_compute_address.proxy_static_ip.address
    }
    subnetwork_project = var.gcp_project_id
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.proxy_server_ssh_key)}"
  }

  metadata_startup_script = file("resources/nginx.sh")

  depends_on = [
    module.vpc
  ]
}

# ==== Firewall ====
resource "google_compute_firewall" "allow-https-kafka" {
  name    = "${var.resource_prefix}-firewall-${var.cc_network_id}"
  network = module.vpc.network_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "9092"]
  }

  direction          = "EGRESS"
  destination_ranges = module.vpc.subnets_ips
}

resource "google_compute_firewall" "proxy_server" {
  name    = "${var.resource_prefix}-firewall-proxy-server"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "9092"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["proxy"]
}