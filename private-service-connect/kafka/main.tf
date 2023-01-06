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

module "cc_sa" {
  source = "./service_accounts"

  resource_prefix           = var.resource_prefix
  environment_id            = var.environment_id
  cluster_id                = var.cluster_id
  cluster_api_version       = var.cluster_api_version
  cluster_kind              = var.cluster_kind
  cluster_admin_id          = var.cluster_admin_id
  cluster_admin_api_version = var.cluster_admin_api_version
  cluster_admin_kind        = var.cluster_admin_kind
}

module "cc_topics" {
  source = "./topics"

  cluster_id                 = var.cluster_id
  cluster_rest_endpoint      = var.cluster_rest_endpoint
  confluent_kafka_api_key    = module.cc_sa.cluster_admin_kafka_api_key.id
  confluent_kafka_api_secret = module.cc_sa.cluster_admin_kafka_api_key.secret

  depends_on = [
    module.cc_sa
  ]
}

module "cc_oauth_pools" {
  source = "./oauth_pools"

  oauth_identity_provider_id = var.oauth_identity_provider_id
  resource_prefix            = var.resource_prefix
  cluster_rbac_crn           = var.cluster_rbac_crn
  environment_id             = var.environment_id
  cluster_id                 = var.cluster_id

  depends_on = [
    module.cc_topics
  ]
}