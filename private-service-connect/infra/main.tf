terraform {
  required_version = ">= 0.14.0"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.23.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

provider "google" {
  credentials = file(var.gcp_creds_path)
  project     = var.gcp_project_id
  region      = var.region
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

module "infra_cc" {
  source = "./modules/infra_cc"

  resource_prefix     = var.resource_prefix
  region              = var.region
  schema_region_id    = var.schema_region_id
  subnet_name_by_zone = var.subnet_name_by_zone
  gcp_project_id      = var.gcp_project_id
  oauth_issuer        = var.oauth_issuer
  oauth_jwks_uri      = var.oauth_jwks_uri
}



module "infra_gcp" {
  source              = "./modules/infra_gcp"
  resource_prefix     = var.resource_prefix
  region              = var.region
  subnet_name_by_zone = var.subnet_name_by_zone
  gcp_project_id      = var.gcp_project_id

  cc_psc_attachments = module.infra_cc.psc_attachements

  cc_hosted_zone = module.infra_cc.hosted_zone
  cc_network_id  = module.infra_cc.network_id

  proxy_server_image   = "ubuntu-os-cloud/ubuntu-2004-lts"
  proxy_server_type    = "e2-medium"
  proxy_server_ssh_key = var.proxy_server_ssh_key

  depends_on = [
    module.infra_cc
  ]
}
